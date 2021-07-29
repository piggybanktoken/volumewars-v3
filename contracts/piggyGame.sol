// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IBEP20.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IRewardNFT is IERC721 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    
    //minter function 
    function mintReward(address recipient, uint256 rewardID) external returns (bool);
    
    //burn  function 
    function burn(address from, uint256 rewardID, uint256 amount) external;
    
     /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);
}

contract piggyGame is Ownable {
    using Address for address;

    // Reward NFT address
    IRewardNFT public rewardNFT;

    // Token grade * 10**9 because that the default piggy decimal
    // uint256 public commonThreshold = 1 *  10**6  * 10**9;
    // uint256 public rareThreshold = 10 * 10**6 *10**9;
    // uint256 public legendaryThreshold = 100 * 10**6  *10**9; 
    
    // The swap router, modifiable.
    IUniswapV2Router02 public pancakeSwapRouter;
    
    // The trading pair
    address public pancakeSwapPair;
    
    //piggy token interface
    IBEP20 private piggyToken;
    address public piggyAddress;

    // Chainlink randomness requests
    struct ChainlinkRequest {
        address requester;
        bool fulfilled;
        uint8 rtype;
        uint8 grade;
    }

    mapping(bytes32 => ChainlinkRequest) requests;

    struct BoosterPack {
        uint256 seed;
        uint8 grade;
    }

    struct Player {
        uint256 gamesPlayed;
        uint256 season;
        uint256 team;
        uint256 experience;
        BoosterPack[] boosterPacks;
    }
    // Players
    mapping(address => Player) public players;

    struct Team {
        bool enabled;
        uint256 wins;
        uint256 damagePoints;
    }

    // Teams
    mapping(uint256 => Team) public teams;

    // User Piggy Balance
    mapping(address => uint256) public balances;
    
    // Thresholds for different booster pack grades
    struct Thresholds {
        uint256 grade1;
        uint256 grade2;
        uint256 grade3;
        uint256 grade4;
    }

    Thresholds public thresholds;

    uint256 latestRID = 0;

    uint256 latestTeam = 0;
    
    bool public open = false;

    uint256 public season = 0;

    uint256 public joinFee = 100000000000000000; // 0.1 ETH

    constructor(IBEP20 _piggyToken, address _router) {
       piggyToken = _piggyToken;
       piggyAddress = address(piggyToken);
       pancakeSwapRouter = IUniswapV2Router02(_router);
       pancakeSwapPair = IUniswapV2Factory(pancakeSwapRouter.factory()).getPair(address(piggyToken), pancakeSwapRouter.WETH());
       require(pancakeSwapPair != address(0), "TEST::updatepancakeSwapRouter: Invalid pair address.");
    }

    event pancakeSwapRouterUpdated(address indexed operator, address indexed router, address indexed pair);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event attacked(address indexed player, uint256 amount);

    // To receive BNB from pancakeSwapRouter when swapping
    receive() external payable {}

    /**
    * @dev Returns the address of the current operator.
    */
    function totalBalance() public view returns (uint256) {
        return piggyToken.balanceOf(address(this));
    }
    function balanceOf(address _player) public view returns (uint256) {
        return balances[_player];
    }
    function bootsterPackBalanceOf(address _player) public view returns(uint256){
        return players[_player].boosterPacks.length;
    }
    function totalgamePlayedOf(address _player) public view returns(uint256){
        return players[_player].gamesPlayed;
    }
    function teamOf(address _player) public view returns(uint256){
        return players[_player].team;
    }
    function setOpen(bool isOpen) public onlyOwner {
        open = isOpen;
    }
    function setSeason(uint256 _season) public onlyOwner {
        season = _season;
    }
    function addTeam() public onlyOwner {
        latestTeam += 1;
        teams[latestTeam].enabled = true;
    }
    function withdrawETH(uint256 amount, address payable _to) public onlyOwner {
        _to.transfer(amount);
    }
    function withdrawAllETH(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
    }
    function setJoinFee(uint256 fee) public onlyOwner {
        joinFee = fee;
    }
    /**
     * @dev Update the swap router.
     * Can only be called by the current operator.
     */
    function updatePancakeSwapRouter(address _router, address _piggyAddress) public onlyOwner {
        piggyAddress = _piggyAddress;
        piggyToken = IBEP20(_piggyAddress);
        pancakeSwapRouter = IUniswapV2Router02(_router);
        pancakeSwapPair = IUniswapV2Factory(pancakeSwapRouter.factory()).getPair(_piggyAddress , pancakeSwapRouter.WETH());
        require(pancakeSwapPair != address(0), "TEST::updatepancakeSwapRouter: Invalid pair address.");
        emit pancakeSwapRouterUpdated(msg.sender, address(pancakeSwapRouter), pancakeSwapPair);
    }
    function updateNFTAddress(IRewardNFT _rewardNFTAddress) public onlyOwner {
        rewardNFT = _rewardNFTAddress;
    }

    function join() public payable {
        require(open, "Game is closed");
        require(msg.value == joinFee, "BNB provided must equal the fee");
        require(players[msg.sender].season != season, "Player has already joined season");
        players[msg.sender].season = season;
        if (players[msg.sender].team == 0) {
            bytes32 requestId = getRandomNumber();
            requests[requestId].requester = msg.sender;
            requests[requestId].rtype = 2;
            requests[requestId].fulfilled = false;
            players[msg.sender].team = 1;
        }
    }
    function buyTokens(uint256 minTokens) public payable {
        require(open, "Game is closed");
        require(msg.value > 0, "No BNB provided");
        uint256 initialTokenBalance = piggyToken.balanceOf(address(this));
        swapEthForExactTokens(msg.value, minTokens);
        uint256 finalTokenBalance = piggyToken.balanceOf(address(this));
        uint256 tokensReceived = finalTokenBalance - initialTokenBalance;
        require(tokensReceived > 0, "No Tokens provided");
        balances[msg.sender] = balances[msg.sender] + tokensReceived;
    }
    function deposit(uint256 amount) public {
        require(open, "Game is closed");
        uint256 tokenbalance = piggyToken.balanceOf(msg.sender);
        require(tokenbalance >= amount, "Insufficient funds");
        uint256 previousBalance = piggyToken.balanceOf(address(this));
        // Transfer tokens to the game contract
        piggyToken.transferFrom(msg.sender, address(this), amount);
        uint256 currentBalance = piggyToken.balanceOf(address(this));
        require(currentBalance - previousBalance > 0, "Negative Balance Increase");
        balances[msg.sender] = balances[msg.sender] + (currentBalance - previousBalance);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        uint256 previousBalance = piggyToken.balanceOf(address(this));
        piggyToken.transfer(msg.sender, amount);
        balances[msg.sender] = balances[msg.sender] - amount;
        uint256 currentBalance = piggyToken.balanceOf(address(this));
        require((previousBalance - currentBalance) == amount, "Contract balance decrease greater than amount");
    }

    function attack(uint256 amount, uint256 team) public {
        require(open, "Game is closed");
        require(season > 0, "Season not set");
        require(players[msg.sender].season == season, "Player has not entered season");
        require(players[msg.sender].team != team, "Cannot attack own team");
        require(players[msg.sender].team != 0, "Player is not on any team");
        require(teams[team].enabled, "Team is not enabled");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        uint256 initialBalance = piggyToken.balanceOf(address(this));
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amount);
        balances[msg.sender] = balances[msg.sender] - amount;

        uint256 afterBalance = piggyToken.balanceOf(address(this));
        uint256 afterETHBalance = address(this).balance;
        require((initialBalance - afterBalance) <= amount, "Contract balance decrease greater than amount"); // Fails on ==, why?
        uint256 ETHReceived = afterETHBalance - initialETHBalance;
        require(ETHReceived > 0, "Negative BNB from selling tokens");

        swapEthForTokens(ETHReceived);
        emit attacked(msg.sender, ETHReceived);

        uint256 finalETHBalance = address(this).balance;
        uint256 finalBalance = piggyToken.balanceOf(address(this));
        require(finalETHBalance >= initialETHBalance, "BNB Balance of contract decreased");
        uint256 tokensReceived = finalBalance - afterBalance;
        require(tokensReceived > 0, "Tokens lost in purchase");
        require(tokensReceived < amount, "Tokens increased after charge and attack");
        balances[msg.sender] = balances[msg.sender] + tokensReceived;

        requestReward(amount);
        players[msg.sender].gamesPlayed += 1;
        players[msg.sender].experience += amount;
        teams[players[msg.sender].team].damagePoints += amount;
    }

    function getRandomNumber() private returns (bytes32 requestId) {
        latestRID += 1;
        return bytes32(abi.encodePacked(latestRID));
    }

    function requestReward(uint256 amount) private {
        if (amount < thresholds.grade1) {
            return;
        }
        bytes32 requestId = getRandomNumber();
        requests[requestId].requester = msg.sender;
        requests[requestId].rtype = 1;
        requests[requestId].fulfilled = false;

        if (amount < thresholds.grade2) {
            requests[requestId].grade = 1;
        } else if (amount < thresholds.grade3) {
            requests[requestId].grade = 2;
        } else if (amount < thresholds.grade4) {
            requests[requestId].grade = 3;
        } else if (amount > thresholds.grade4) {
            requests[requestId].grade = 4;
        }
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal { // override
        if (requests[requestId].fulfilled) {
            return;
        }
        requests[requestId].fulfilled = true;

        // rtype 1: Booster pack
        if (requests[requestId].rtype == 1) {
            players[requests[requestId].requester].boosterPacks.push(BoosterPack({
                grade: requests[requestId].grade,
                seed: randomness
            }));
        }
        // rtype 1: Team Assignment
        if (requests[requestId].rtype == 2) {
            uint256 team = (randomness % latestTeam) + 1;
            players[requests[requestId].requester].team = team;
        }
    }

    function unpackBoosterPack() public {
        uint numPacks = players[msg.sender].boosterPacks.length;
        require(numPacks > 0, "No booster packs to unpack");
        uint256 seed = players[msg.sender].boosterPacks[numPacks-1].seed;
        uint8 grade = players[msg.sender].boosterPacks[numPacks-1].grade;
        rewardPlayer(seed, grade);
        players[msg.sender].boosterPacks.pop();
    }

    function rewardPlayer(uint256 seed, uint8 grade) private {
        require(grade > 0, "Grade too low");
        require(grade <= 4, "Grade too high");
        uint8 numCommon = 0;
        uint8 numRare = 0;
        uint8 nonce = 1;
        if (grade == 1) { // Grade 1: No rares, 0 to 1 Common NFTs
            numCommon = getRandomInt(1, seed, nonce);
        } else if (grade == 2) { // Grade 2: 0 to 1 Common NFTs, 1 in 10 Chance of Rare
            numCommon = getRandomInt(1, seed, nonce);
            if (getRandomInt(10, seed, nonce+1) == 10) {
                numRare = 1;
            }
        } else if (grade == 3) { // Grade 2: 0 to 2 Common NFTs, 1 in 8 Chance of Rare
            numCommon = getRandomInt(2, seed, nonce);
            if (getRandomInt(7, seed, nonce+1) == 7) {
                numRare = 1;
            }
        } else if (grade == 4) { // Grade 2: 1 to 3 Common NFTs, 1 in 5 Chance of Rare
            numCommon = getRandomInt(2, seed, nonce) + 1;
            if (getRandomInt(4, seed, nonce+1) == 4) {
                numRare = 1;
            }
        }
        assignNFTs(numCommon, numRare, seed);
    }

    function assignNFTs(uint8 numCommon, uint8 numRare, uint256 seed) private {
        if (numCommon == 0 && numRare == 0) {
            return;
        }
        uint8 nonce = 10;
        require(numCommon <= 3, "Too many common NFTs generated");
        require(numRare <= 1, "Too many rare NFTs generated");
        for (uint256 i = 0 ; i < numCommon ; i++) {
            getRandomInt(7, seed, nonce+1);
            // Mint Common NFT
        }
        if (numRare == 1) {
            // Mint Rare NFT
            rewardNFT.mintReward(msg.sender, 6);
        }
    }

    function getRandomInt(uint8 max, uint256 seed, uint8 nonce) pure private returns(uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(seed, nonce))) % (max+1));
    }
    
    function setThresholds(uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4) public onlyOwner {
        thresholds = Thresholds({
            grade1: grade1, 
            grade2: grade2,
            grade3: grade3,
            grade4: grade4
        });
    }

    /// @dev Swap tokens for eth
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the testSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = piggyAddress;
        path[1] = pancakeSwapRouter.WETH();

        piggyToken.approve(address(pancakeSwapRouter), tokenAmount*2);
        
        // make the swap
        pancakeSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
           tokenAmount,
            0, // get anything we can
            path,
            address(this),
            block.timestamp
        );
    }
    
    // @dev Swap tokens for eth
    function swapEthForTokens(uint256 EthAmount ) private {
        // generate the testSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeSwapRouter.WETH();
        path[1] = piggyAddress;

        // make the swap
        pancakeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
           0 ,// get anything we can
            path,
             address(this),
            block.timestamp
        );
    }
    // @dev Swap tokens for eth
    function swapEthForExactTokens(uint256 EthAmount, uint256 minTokens) private {
        // generate the testSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = pancakeSwapRouter.WETH();
        path[1] = piggyAddress;

        // make the swap
        pancakeSwapRouter.swapETHForExactTokens{value: EthAmount}(
            minTokens,// get anything we can
            path,
            address(this),
            block.timestamp
        );
    }

    function inRange(uint256 lowerLimit  , uint256  upperLimit, uint256 value) internal pure returns(bool){
        if(value >= lowerLimit && value <= upperLimit) {
            return true;
        }
        return false;
    }
}