// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

import "./IBEP20.sol";

interface IRewardNFT is IERC721 {
    function mint(address to, uint16 set, uint8 number) external;
    function metadataOf(uint256 id) external returns (uint16, uint8);
    function totalCardsOf(uint16 id) external returns (uint8);
    function forgeBurn(uint256 id) external;
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
        uint16 season;
        uint32 team;
        uint32 winsBeforeJoin;
        uint256 experience;
        BoosterPack[] boosterPacks;
    }
    // Players
    mapping(address => Player) public players;

    struct Team {
        bool enabled;
        uint32 wins;
        uint256 damagePoints;
    }

    // Teams
    mapping(uint32 => Team) public teams;

    uint32 latestTeam = 0;

    uint32[] activeTeams;

    // User Piggy Balance
    mapping(address => uint256) public balances;
    
    // Thresholds for different booster pack grades
    struct Thresholds {
        uint256 grade1;
        uint256 grade2;
        uint256 grade3;
        uint256 grade4;
    }

    Thresholds public thresholds = Thresholds({
        grade1: 10   * 10**9 * 10**9,
        grade2: 50   * 10**9 * 10**9,
        grade3: 150  * 10**9 * 10**9,
        grade4: 500  * 10**9 * 10**9
    });

    struct RareChance {
        uint8 grade2;
        uint8 grade3;
        uint8 grade4;
    }
    RareChance public rareChance = RareChance({
        grade2: 30, // 1 in 30 Chance
        grade3: 10, // 1 in 10 Chance
        grade4: 5   // 1 in 5 Chance
    });

    uint256 latestRID = 0;
    
    bool public open = false;

    uint16 public season = 0;

    uint256 public joinFee = 100000000000000000; // 0.1 ETH

    constructor(IBEP20 _piggyToken, address _router) {
       piggyToken = _piggyToken;
       piggyAddress = address(piggyToken);
       pancakeSwapRouter = IUniswapV2Router02(_router);
       pancakeSwapPair = IUniswapV2Factory(pancakeSwapRouter.factory()).getPair(address(piggyToken), pancakeSwapRouter.WETH());
       require(pancakeSwapPair != address(0), "TEST::updatepancakeSwapRouter: Invalid pair address.");
    }

    event pancakeSwapRouterUpdated(address indexed operator, address indexed router, address indexed pair);
    event SetOpen(address indexed owner, bool indexed open);
    event SetSeason(address indexed owner, uint32 indexed season);
    event SetJoinFee(address indexed owner, uint256 fee);
    event SeasonClose(address indexed owner, uint32 indexed season, uint32 indexed winner);
    event SeasonOpen(address indexed owner, uint32 indexed season);
    event TeamAdded(address indexed owner, uint32 indexed team);
    event OwnerWithdrawal(address indexed owner, address indexed to, uint256 amount);
    event JoinedGame(address indexed player, uint256 indexed season);
    event TokensPurchased(address indexed player, uint256 amount, uint256 minAmount, uint256 BNBSent);
    event Deposit(address indexed player, uint256 amount);
    event Withdrawal(address indexed player, uint256 amount);
    event Attack(address indexed player, uint32 indexed team, uint256 amount, uint256 ethAmount, uint256 tokensReturned, uint256 BalanceChange);
    event RandomNumberRequest(address indexed requester, bytes32 id);
    event RandomNumberFulfilled(address indexed requester, uint8 indexed rtype, bytes32 id, uint256 randomness);
    event ReceivedBoosterBack(address indexed requester, uint8 indexed grade, uint256 randomness);
    event TeamAssigned(address indexed requester, uint32 indexed team, uint256 randomness);
    event BoosterPackOpened(address indexed player, uint8 indexed grade, uint256 seed);
    event NFTAwarded(address indexed player, uint16 indexed set, uint8 indexed number, bool rare);
    event LegendaryForged(address indexed player, uint16 indexed set);
    event ThresholdsSet(address indexed owner, uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4);
    event RareChanceSet(address indexed owner, uint256 grade2, uint256 grade3, uint256 grade4);

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
    function playerWins(address _player) public view returns(uint32){
        uint32 team = players[_player].team;
        uint32 winsBeforeJoin = players[_player].winsBeforeJoin;
        require(teams[team].wins >= winsBeforeJoin, "Wins before join higher than total wins");
        return teams[team].wins - winsBeforeJoin;
    }
    function setOpen(bool isOpen) public onlyOwner {
        open = isOpen;
        emit SetOpen(msg.sender, open);
    }
    function setSeason(uint16 _season) public onlyOwner {
        season = _season;
        emit SetSeason(msg.sender, season);
    }
    function openSeason() public onlyOwner {
        season += 1;
        open = true;
        emit SetSeason(msg.sender, season);
        emit SeasonOpen(msg.sender, season);
        emit SetOpen(msg.sender, open);
    }
    function closeSeason() public onlyOwner {
        open = false;
        uint256 lowestDamagePoints = teams[activeTeams[0]].damagePoints;
        uint32 winningTeam = activeTeams[0];
        for (uint32 i = 0; i < activeTeams.length; i++) {
            uint256 teamDamagePoints = teams[activeTeams[i]].damagePoints;
            if (teamDamagePoints < lowestDamagePoints){
                lowestDamagePoints = teamDamagePoints;
                winningTeam = activeTeams[i];
            }
            teams[activeTeams[i]].damagePoints = 0;
        }
        teams[winningTeam].wins += 1;
        emit SeasonClose(msg.sender, season, winningTeam);
        emit SetOpen(msg.sender, open);
    }

    function addTeam() public onlyOwner {
        latestTeam += 1;
        teams[latestTeam].enabled = true;
        activeTeams.push(latestTeam);
        emit TeamAdded(msg.sender, latestTeam);
    }
    function withdrawETH(uint256 amount, address payable _to) public onlyOwner {
        _to.transfer(amount);
        emit OwnerWithdrawal(msg.sender, _to, amount);
    }
    function withdrawAllETH(address payable _to) public onlyOwner {
        _to.transfer(address(this).balance);
        emit OwnerWithdrawal(msg.sender, _to, address(this).balance);
    }
    function setJoinFee(uint256 fee) public onlyOwner {
        joinFee = fee;
        emit SetJoinFee(msg.sender, fee);
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
        emit JoinedGame(msg.sender, season);
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
        emit TokensPurchased(msg.sender, tokensReceived, minTokens, msg.value);
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
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        uint256 previousBalance = piggyToken.balanceOf(address(this));
        piggyToken.transfer(msg.sender, amount);
        balances[msg.sender] = balances[msg.sender] - amount;
        uint256 currentBalance = piggyToken.balanceOf(address(this));
        require((previousBalance - currentBalance) == amount, "Contract balance decrease greater than amount");
        emit Withdrawal(msg.sender, amount);
    }

    function attack(uint256 amount, uint32 team) public {
        require(open, "Game is closed");
        require(season > 0, "Season not set");
        require(players[msg.sender].season == season, "Player has not entered season");
        require(players[msg.sender].team != team, "Cannot attack own team");
        require(players[msg.sender].team != 0, "Player is not on any team");
        require(teams[team].enabled, "Team is not enabled");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        uint256 initialBalance = piggyToken.balanceOf(address(this));
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amount); // Sell tokens for ETH

        uint256 afterBalance = piggyToken.balanceOf(address(this));
        uint256 afterETHBalance = address(this).balance;

        uint256 tokensSold = initialBalance - afterBalance; // Tokens sold in the first swap
        require(tokensSold <= amount, "Contract balance decrease greater than amount"); // Fails on ==, why?

        uint256 ETHReceived = afterETHBalance - initialETHBalance; // ETH Received from token sale
        require(ETHReceived > 0, "Negative BNB from selling tokens");

        swapEthForTokens(ETHReceived); // Buy tokens for ETH

        require(address(this).balance == initialETHBalance, "BNB Balance of contract changed");

        uint256 tokensReceived = piggyToken.balanceOf(address(this)) - afterBalance;
        require(tokensReceived > 0, "Tokens lost in purchase");
        require(tokensReceived < amount, "Tokens increased after charge and attack");
        require(initialBalance - piggyToken.balanceOf(address(this)) > 0, "Piggy balance did not decrease");
        require(initialBalance - piggyToken.balanceOf(address(this)) < balances[msg.sender], "Player cannot pay for balance decrease");

        // Change in piggy balance is charged to the player
        balances[msg.sender] -= initialBalance - piggyToken.balanceOf(address(this));

        requestReward(amount);
        players[msg.sender].gamesPlayed += 1;
        players[msg.sender].experience += amount;
        teams[players[msg.sender].team].damagePoints += amount;
        emit Attack(
        msg.sender, 
        team,
        amount, 
        ETHReceived,
        tokensReceived,
        initialBalance - piggyToken.balanceOf(address(this)));
    }

    function getRandomNumber() private returns (bytes32 requestId) {
        latestRID += 1;
        emit RandomNumberRequest(msg.sender, bytes32(abi.encodePacked(latestRID)));
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
        emit RandomNumberFulfilled(requests[requestId].requester, requests[requestId].rtype, requestId, randomness);
        requests[requestId].fulfilled = true;

        // rtype 1: Booster pack
        if (requests[requestId].rtype == 1) {
            players[requests[requestId].requester].boosterPacks.push(BoosterPack({
                grade: requests[requestId].grade,
                seed: randomness
            }));
            emit ReceivedBoosterBack(requests[requestId].requester, requests[requestId].grade, randomness);
        }
        // rtype 1: Team Assignment
        if (requests[requestId].rtype == 2) {
            uint32 teamIndex = uint32(randomness % activeTeams.length);
            players[requests[requestId].requester].team = activeTeams[teamIndex];
            players[requests[requestId].requester].winsBeforeJoin = teams[activeTeams[teamIndex]].wins;
            emit TeamAssigned(requests[requestId].requester, activeTeams[teamIndex], randomness);
        }
    }

    function unpackBoosterPack() public {
        uint numPacks = players[msg.sender].boosterPacks.length;
        require(numPacks > 0, "No booster packs to unpack");
        uint256 seed = players[msg.sender].boosterPacks[numPacks-1].seed;
        uint8 grade = players[msg.sender].boosterPacks[numPacks-1].grade;
        rewardPlayer(seed, grade);
        players[msg.sender].boosterPacks.pop();
        emit BoosterPackOpened(msg.sender, grade, seed);
    }

    function rewardPlayer(uint256 seed, uint8 grade) private {
        require(grade > 0, "Grade too low");
        require(grade <= 4, "Grade too high");
        uint8 numCommon = 0;
        uint8 numRare = 0;
        uint8 nonce = 1;
        if (grade == 1) { // Grade 1: 1 in 3 chance of Common NFT, No Rare
            // Common, 1 in 3 chance
            if (getRandomInt(2, seed, nonce) == 0) {
                numCommon = 1;
            }
        } else if (grade == 2) { // Grade 2: 0 to 1 Common NFTs, 1 in rareChance.grade2 Chance of Rare
            // Common
            numCommon = getRandomInt(1, seed, nonce);
            nonce +=1;
            // Rare
            if (getRandomInt(rareChance.grade2-1, seed, nonce) == 0) {
                numRare = 1;
            }
        } else if (grade == 3) { // Grade 2: 0 to 2 Common NFTs, 1 in rareChance.grade3 Chance of Rare
            // Common
            numCommon = getRandomInt(2, seed, nonce);
            nonce +=1;
            // Rare
            if (getRandomInt(rareChance.grade3-1, seed, nonce) == 0) {
                numRare = 1;
            }
        } else if (grade == 4) { // Grade 2: 1 to 3 Common NFTs, 1 in rareChance.grade4 Chance of Rare
            // Common
            numCommon = getRandomInt(2, seed, nonce) + 1;
            nonce +=1;
            // Rare
            if (getRandomInt(rareChance.grade4-1, seed, nonce) == 0) {
                numRare = 1;
            }
        }
        if (numCommon == 0 && numRare == 0) {
            return;
        }
        assignNFTs(numCommon, numRare, seed);
    }

    function assignNFTs(uint8 numCommon, uint8 numRare, uint256 seed) private {
        uint8 nonce = 10;
        require(numCommon <= 3, "Too many common NFTs generated");
        require(numRare <= 1, "Too many rare NFTs generated");
        for (uint8 i = 0 ; i < numCommon; i++) {
            nonce += 1;
            // Mint Common NFT
            uint8 number = getRandomInt(3, seed, nonce) + 1; // 0-3 + 1 = 1-4
            rewardNFT.mint(msg.sender, season, number);
            emit NFTAwarded(msg.sender, season, number, false);
        }
        if (numRare == 1) {
            nonce +=1;
            // Mint Rare NFT
            uint8 number = getRandomInt(2, seed, nonce) + 5; // 0-2 + 5 = 5-7
            rewardNFT.mint(msg.sender, season, number);
            emit NFTAwarded(msg.sender, season, number, true);
        }
    }

    function getRandomInt(uint8 max, uint256 seed, uint8 nonce) pure private returns(uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(seed, nonce))) % (max+1));
    }

    function forgeLegendary(uint256[] calldata ids) public {
        (uint16 cardSet, uint8 _number) = rewardNFT.metadataOf(ids[0]);
        require(_number == 1, "First card must be 1");
        uint8 totalCards = rewardNFT.totalCardsOf(cardSet);
        require(totalCards == ids.length, "Wrong amount of cards to complete the set");

        for (uint8 i = 0 ; i < totalCards; i++) {
            require(rewardNFT.ownerOf(ids[i]) == msg.sender, "Sender does not own the NFT");
            (uint16 set, uint8 number) = rewardNFT.metadataOf(ids[i]);
            require(set == cardSet, "Card from wrong set");
            require(number == (i+1), "Wrong card number or order"); // Cards are from 1 to totalCards, i is from 0 to totalCards - 1
            rewardNFT.forgeBurn(ids[i]); // Burn NFT
        }
        rewardNFT.mint(msg.sender, cardSet, 0); // Card 0 of set is Legendary
        emit LegendaryForged(msg.sender, cardSet);
    }
    
    function setThresholds(uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4) public onlyOwner {
        thresholds = Thresholds({
            grade1: grade1, 
            grade2: grade2,
            grade3: grade3,
            grade4: grade4
        });
        emit ThresholdsSet(msg.sender, grade1, grade2, grade3, grade4);
    }

    function setRareChance(uint8 grade2, uint8 grade3, uint8 grade4) public onlyOwner {
        rareChance = RareChance({
            grade2: grade2,
            grade3: grade3,
            grade4: grade4
        });
        emit RareChanceSet(msg.sender, grade2, grade3, grade4);
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

        // Make the swap
        pancakeSwapRouter.swapETHForExactTokens{value: EthAmount}(
            minTokens,// get anything we can
            path,
            address(this),
            block.timestamp
        );
    }

    function inRange(uint256 lowerLimit, uint256 upperLimit, uint256 value) internal pure returns(bool){
        if(value >= lowerLimit && value <= upperLimit) {
            return true;
        }
        return false;
    }
    function mintNFT(address to, uint16 set, uint8 number) public onlyOwner {
        rewardNFT.mint(to, set, number);
    }
}