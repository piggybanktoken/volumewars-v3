// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

import "./IBEP20.sol";

interface IRewardNFT is IERC721 {
    function mint(address to, uint16 set, uint8 number) external;
    function metadataOf(uint256 id) external returns (uint16, uint8);
    function totalCardsOf(uint16 id) external returns (uint8);
    function forgeBurn(uint256 id) external;
    function addSet(uint16 set, uint8 number) external;
}

contract piggyGame is Ownable, VRFConsumerBase  {
    using Address for address;

    // Reward NFT address
    IRewardNFT public rewardNFT;
    
    // The swap router, modifiable.
    IUniswapV2Router02 public pancakeSwapRouter;
    
    //piggy token interface
    // IBEP20 private piggyToken;
    // address public piggyAddress;

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
        address team;
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
    mapping(address => Team) public teams;

    uint32 public latestTeam = 0;

    address[] public activeTeams;

    // User Piggy Balance
    mapping(address => uint256) public balances;

    struct RewardPool {
        uint256 balance; // BNB Balance
        uint256 remainingClaims; // claims not yet made
        uint256 rewardPerNFT; // How much each NFT gets
        bool open; // Whether it can be withdrawn from
        mapping(uint256 => bool) nftsClaimed; // ID of NFTs that have already claimed this prize
    }
    // Reward pools (season -> pools)
    mapping (uint16 => RewardPool) rewardPools;
    
    // Thresholds for different booster pack grades
    struct Thresholds {
        uint256 grade1;
        uint256 grade2;
        uint256 grade3;
        uint256 grade4;
    }

    
    mapping(address => Thresholds) thresholds;
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

    mapping (uint8 => uint256) createdCards; // Counter for each card number created

    uint256 latestRID = 0;
    
    bool public open = false;

    uint16 public season = 0;

    uint256 public joinFee = 10000000000000000; // 0.01 BNB
    
    // Chainlink
    bytes32 internal keyHash;
    uint256 internal fee;

    // Dev rewards
    uint256 devPool;

    address piggyAddress;
    uint256 minPiggy = 10 * 10**8 * 10**9; // Min piggy to hold in order to join

    address linkAddress;

    constructor(address _piggyToken, address _secondToken, address _router, address _coordinator, address _linkToken, bytes32 _hash, uint256 _fee)
        VRFConsumerBase(
            _coordinator,
            _linkToken
        )
     {
        keyHash = _hash;
        fee = _fee;
        pancakeSwapRouter = IUniswapV2Router02(_router);
        piggyAddress = _piggyToken;
        linkAddress = _linkToken;

        Thresholds memory thresholdSet = Thresholds({
            grade1: 10   * 10**8 * 10**9,
            grade2: 2   * 10**9 * 10**9,
            grade3: 3  * 10**9 * 10**9,
            grade4: 5  * 10**9 * 10**9
        });
        addTeam(_piggyToken, thresholdSet.grade1, thresholdSet.grade2, thresholdSet.grade3, thresholdSet.grade4);

        Thresholds memory thresholdSet2 = Thresholds({
            grade1: 0.01 * 10**9,
            grade2: 0.02 * 10**9,
            grade3: 0.10 * 10**9,
            grade4: 0.20 * 10**9
        });
        addTeam(_secondToken, thresholdSet2.grade1, thresholdSet2.grade2, thresholdSet2.grade3, thresholdSet2.grade4);
    }

    event PancakeSwapRouterUpdated(address indexed operator, address indexed router);
    event SetOpen(address indexed owner, bool indexed open);
    event SetSeason(address indexed owner, uint32 indexed season);
    event SetJoinFee(address indexed owner, uint256 fee);
    event SetMinPiggy(address indexed owner, uint256 amount);
    event SeasonClose(address indexed owner, uint32 indexed season, address indexed winner);
    event SeasonOpen(address indexed owner, uint32 indexed season);
    event TeamAdded(address indexed owner, address indexed team);
    event OwnerWithdrawal(address indexed owner, address indexed to, uint256 amount);
    event JoinedGame(address indexed player, uint256 indexed season, address indexed team);
    event TokensPurchased(address indexed player, uint256 amount, uint256 minAmount, uint256 BNBSent);
    event Deposit(address indexed player, uint256 amount);
    event Withdrawal(address indexed player, uint256 amount);
    event Attack(address indexed player, address indexed team, uint256 amount, uint256 ethAmount, uint256 tokensReturned, uint256 BalanceChange);
    event RandomNumberRequest(address indexed requester, bytes32 id);
    event RandomNumberFulfilled(address indexed requester, uint8 indexed rtype, bytes32 id, uint256 randomness);
    event ReceivedBoosterBack(address indexed requester, uint8 indexed grade, uint256 randomness);
    event TeamAssigned(address indexed player, address indexed team);
    event BoosterPackOpened(address indexed player, uint8 indexed grade, uint256 seed);
    event NFTAwarded(address indexed player, uint16 indexed set, uint8 indexed number, bool rare);
    event LegendaryForged(address indexed player, uint16 indexed set);
    event ThresholdsSet(address indexed owner, uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4);
    event RareChanceSet(address indexed owner, uint256 grade2, uint256 grade3, uint256 grade4);
    event PoolOpened(uint16 indexed season, uint256 totalClaims, uint256 initialBalance, uint256 rewardPerNFT);
    event LegendaryRewardClaimed(uint16 indexed rewardSeason, uint16 indexed currentSeason, uint256 indexed NFT, uint16 NFTSet);
    event PoolClosedAndFundsTransferred(uint16 indexed poolSeason, uint16 indexed currentSeason, uint256 amount);

    // To receive BNB from pancakeSwapRouter when swapping
    receive() external payable {}

    function totalBalanceOfToken(address tokenAddress) public view returns (uint256) {
        return IBEP20(tokenAddress).balanceOf(address(this));
    }
    function totalBalance() public view returns (uint256) {
        return totalBalanceOfToken(players[msg.sender].team);
    }
    function getJoinFee() public view returns (uint256) {
        return joinFee;
    }
    function isGameOpen() public view returns (bool) {
        return open;
    }
    function currentSeason() public view returns (uint16) {
        return season;
    }
    function balanceOf(address _player) public view returns (uint256) {
        return balances[_player];
    }
    function boosterPackBalanceOf(address _player) public view returns(uint256){
        return players[_player].boosterPacks.length;
    }
    function totalGamesPlayedOf(address _player) public view returns(uint256){
        return players[_player].gamesPlayed;
    }
    function teamOf(address _player) public view returns(address){
        return players[_player].team;
    }
    function getThresholds() public view returns(uint256, uint256, uint256, uint256) {
        address teamAddress = players[msg.sender].team;
        return (thresholds[teamAddress].grade1, thresholds[teamAddress].grade2, thresholds[teamAddress].grade3, thresholds[teamAddress].grade4);
    }
    function getTeamThresholds(address teamAddress) public view returns(uint256, uint256, uint256, uint256) {
        return (thresholds[teamAddress].grade1, thresholds[teamAddress].grade2, thresholds[teamAddress].grade3, thresholds[teamAddress].grade4);
    }
    function hasPlayerJoined(address _player) public view returns(bool) {
        return players[_player].season == season;
    }
    function getRareChances() public view returns(uint8, uint8, uint8) {
        return (rareChance.grade2, rareChance.grade3, rareChance.grade4);
    }
    function teamDamageOf(address teamId) public view returns(uint256) {
        return teams[teamId].damagePoints;
    }
    function teamWinsOf(address teamId) public view returns(uint32) {
        return teams[teamId].wins;
    }
    function getActiveTeams() public view returns(address[] memory) {
        return activeTeams;
    }
    function playerWins(address _player) public view returns(uint32){
        address team = players[_player].team;
        uint32 winsBeforeJoin = players[_player].winsBeforeJoin;
        require(teams[team].wins >= winsBeforeJoin, "Wins before join higher than total wins");
        return teams[team].wins - winsBeforeJoin;
    }
    function tokenDecimals(address player) public view returns (uint8) {
        address teamAddress = players[player].team;
        return teamTokenDecimalsFor(teamAddress);
    }
    function teamTokenDecimalsFor(address teamAddress) public view returns (uint8) {
        return IBEP20(teamAddress).decimals();
    }
    function tokenSymbol(address player) public view returns (string memory) {
        address teamAddress = players[player].team;
        return teamTokenSymbolFor(teamAddress);
    }
    function teamTokenSymbolFor(address teamAddress) public view returns (string memory) {
        return IBEP20(teamAddress).symbol();
    }
    function tokenName(address player) public view returns (string memory) {
        address teamAddress = players[player].team;
        return teamTokenSymbolFor(teamAddress);
    }
    function teamTokenNameFor(address teamAddress) public view returns (string memory) {
        return IBEP20(teamAddress).name();
    }
    function userTokenBalance(address player) public view returns (uint256) {
        address teamAddress = players[player].team;
        return IBEP20(teamAddress).balanceOf(player);
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
        require(open == false, "Season currently open");
        season += 1;
        open = true;
        rewardNFT.addSet(season, 7);
        emit SetSeason(msg.sender, season);
        emit SeasonOpen(msg.sender, season);
        emit SetOpen(msg.sender, open);
    }
    function closeSeason() public onlyOwner {
        open = false;
        uint256 lowestDamagePoints = teams[activeTeams[0]].damagePoints;
        address winningTeam = activeTeams[0];
        for (uint32 i = 0; i < activeTeams.length; i++) {
            uint256 teamDamagePoints = teams[activeTeams[i]].damagePoints;
            if (teamDamagePoints < lowestDamagePoints){
                lowestDamagePoints = teamDamagePoints;
                winningTeam = activeTeams[i];
            }
            teams[activeTeams[i]].damagePoints = 0;
        }
        teams[winningTeam].wins += 1;
        openPool();
        emit SeasonClose(msg.sender, season, winningTeam);
        emit SetOpen(msg.sender, open);
    }

    function addTeam(address teamTokenAddress, uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4) public onlyOwner {
        teams[teamTokenAddress].enabled = true;
        activeTeams.push(teamTokenAddress);
        setThresholds(teamTokenAddress, grade1, grade2, grade3, grade4);
        require(IUniswapV2Factory(pancakeSwapRouter.factory()).getPair(teamTokenAddress, pancakeSwapRouter.WETH()) != address(0), "Add Team: Invalid pair address.");
        emit TeamAdded(msg.sender, teamTokenAddress);
    }

    function withdrawAllDevETH(address payable _to) public onlyOwner {
        require(devPool > 0, "No funds in dev pool");
        uint256 withdrawAmount = devPool;
        devPool = 0;
        _to.transfer(withdrawAmount);
        emit OwnerWithdrawal(msg.sender, _to, devPool);
    }
    function withdrawLink(address payable _to, uint256 amount) public onlyOwner {
        IBEP20(linkAddress).transfer(_to, amount);
    }
    function setJoinFee(uint256 _fee) public onlyOwner {
        joinFee = _fee;
        emit SetJoinFee(msg.sender, _fee);
    }
    function setJoinPiggy(uint256 _amount) public onlyOwner {
        minPiggy = _amount;
        emit SetMinPiggy(msg.sender, _amount);
    }
    /**
     * @dev Update the swap router.
     * Can only be called by the current operator.
     */
    function updatePancakeSwapRouter(address _router) public onlyOwner {
        pancakeSwapRouter = IUniswapV2Router02(_router);
        emit PancakeSwapRouterUpdated(msg.sender, address(pancakeSwapRouter));
    }
    function updateNFTAddress(IRewardNFT _rewardNFTAddress) public onlyOwner {
        rewardNFT = _rewardNFTAddress;
    }

    function join(address teamTokenAddress) public payable {
        require(open, "Game is closed");
        require(msg.value == joinFee, "BNB provided must equal the fee");
        require(players[msg.sender].season != season, "Player has already joined season");
        require(IBEP20(piggyAddress).balanceOf(msg.sender) >= minPiggy, "Not enough piggy in account");
        players[msg.sender].season = season;

        // Add join fee to reward pool for this season
        uint256 userDeposit = msg.value;
        devPool += userDeposit/2;
        userDeposit -= userDeposit/2;
        rewardPools[season].balance += userDeposit;
        
        if (players[msg.sender].team == address(0)) {
            require(teams[teamTokenAddress].enabled == true, "Team not enabled");
            players[msg.sender].team = teamTokenAddress;
            emit TeamAssigned(msg.sender, teamTokenAddress);
        }
        emit JoinedGame(msg.sender, season, teamTokenAddress);
    }

    function buyTokens(uint256 minTokens) public payable {
        require(open, "Game is closed");
        require(msg.value > 0, "No BNB provided");
        require(players[msg.sender].team != address(0), "User must be in a team");
        IBEP20 teamToken = IBEP20(players[msg.sender].team);
        uint256 initialTokenBalance = teamToken.balanceOf(address(this));
        swapEthForExactTokens(msg.value, minTokens);
        uint256 finalTokenBalance = teamToken.balanceOf(address(this));
        require(finalTokenBalance > initialTokenBalance, "No Tokens provided");
        balances[msg.sender] = balances[msg.sender] + finalTokenBalance - initialTokenBalance;
        emit TokensPurchased(msg.sender, finalTokenBalance - initialTokenBalance, minTokens, msg.value);
    }
    function deposit(uint256 amount) public {
        require(open, "Game is closed");
        require(players[msg.sender].team != address(0), "User must be in a team");
        IBEP20 teamToken = IBEP20(players[msg.sender].team);
        uint256 tokenbalance = teamToken.balanceOf(msg.sender);
        require(tokenbalance >= amount, "Insufficient funds");
        uint256 previousBalance = teamToken.balanceOf(address(this));
        // Transfer tokens to the game contract
        teamToken.transferFrom(msg.sender, address(this), amount);
        uint256 currentBalance = teamToken.balanceOf(address(this));
        require(currentBalance > previousBalance, "Negative Balance Increase");
        balances[msg.sender] = balances[msg.sender] + (currentBalance - previousBalance);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        require(players[msg.sender].team != address(0), "User must be in a team");
        IBEP20 teamToken = IBEP20(players[msg.sender].team);
        uint256 previousBalance = teamToken.balanceOf(address(this));
        teamToken.transfer(msg.sender, amount);
        balances[msg.sender] = balances[msg.sender] - amount;
        require((previousBalance - teamToken.balanceOf(address(this))) <= amount, "Contract balance decrease greater than amount");
        emit Withdrawal(msg.sender, amount);
    }

    function attack(uint256 amount, address team) public {
        require(open, "Game is closed");
        require(season > 0, "Season not set");
        require(players[msg.sender].season == season, "Player has not entered season");
        require(players[msg.sender].team != team, "Cannot attack own team");
        require(players[msg.sender].team != address(0), "Player is not on any team");
        require(teams[team].enabled, "Team is not enabled");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        // The team's corresponding token
        IBEP20 teamToken = IBEP20(players[msg.sender].team);

        uint256 initialBalance = teamToken.balanceOf(address(this));
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amount); // Sell tokens for ETH

        uint256 afterBalance = teamToken.balanceOf(address(this));
        uint256 afterETHBalance = address(this).balance;

        uint256 tokensSold = initialBalance - afterBalance; // Tokens sold in the first swap
        require(tokensSold <= amount, "Contract balance decrease greater than amount"); // Fails on ==, why?

        uint256 ETHReceived = afterETHBalance - initialETHBalance; // ETH Received from token sale
        require(afterETHBalance > initialETHBalance, "Negative BNB from selling tokens");

        swapEthForTokens(ETHReceived); // Buy tokens for ETH

        require(address(this).balance == initialETHBalance, "BNB Balance of contract changed");

        uint256 tokensReceived = teamToken.balanceOf(address(this)) - afterBalance;
        require(teamToken.balanceOf(address(this)) > afterBalance, "Tokens lost in purchase");
        require(tokensReceived < amount, "Tokens increased after charge and attack");
        require(initialBalance > teamToken.balanceOf(address(this)), "Piggy balance did not decrease");
        require((initialBalance - teamToken.balanceOf(address(this))) < balances[msg.sender], "Player cannot pay for balance decrease");

        // Change in piggy balance is charged to the player
        balances[msg.sender] -= initialBalance - teamToken.balanceOf(address(this));

        requestReward(amount);
        players[msg.sender].gamesPlayed += 1;
        players[msg.sender].experience += ETHReceived;
        teams[team].damagePoints += ETHReceived;
        emit Attack(
        msg.sender, 
        team,
        amount, 
        ETHReceived,
        tokensReceived,
        initialBalance - teamToken.balanceOf(address(this)));
    }

    function getRandomNumber() private returns (bytes32 requestId) {
        emit RandomNumberRequest(msg.sender, bytes32(abi.encodePacked(latestRID)));
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    function requestReward(uint256 amount) private {
        address teamAddress = players[msg.sender].team;
        if (amount < thresholds[teamAddress].grade1) {
            return;
        }
        bytes32 requestId = getRandomNumber();
        requests[requestId].requester = msg.sender;
        requests[requestId].rtype = 1;
        requests[requestId].fulfilled = false;

        if (amount < thresholds[teamAddress].grade2) {
            requests[requestId].grade = 1;
        } else if (amount < thresholds[teamAddress].grade3) {
            requests[requestId].grade = 2;
        } else if (amount < thresholds[teamAddress].grade4) {
            requests[requestId].grade = 3;
        } else if (amount > thresholds[teamAddress].grade4) {
            requests[requestId].grade = 4;
        }
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
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
    }

    function unpackBoosterPack() public {
        uint numPacks = players[msg.sender].boosterPacks.length;
        require(numPacks > 0, "No booster packs to unpack");
        uint256 seed = players[msg.sender].boosterPacks[numPacks-1].seed;
        uint8 grade = players[msg.sender].boosterPacks[numPacks-1].grade;
        (uint8 numCommon, bool getRare) = getNumRewards(seed, grade, rareChance.grade2-1, rareChance.grade3-1, rareChance.grade4-1);
        assignNFTs(numCommon, getRare, seed);
        players[msg.sender].boosterPacks.pop();
        emit BoosterPackOpened(msg.sender, grade, seed);
    }
    function getNumRewards(uint256 seed, uint8 grade, uint8 grade2RareChance, uint8 grade3RareChance, uint8 grade4RareChance) public pure returns(uint8, bool) { // Common, Rare
        require(grade > 0, "Grade too low");
        require(grade <= 4, "Grade too high");
        if (grade == 1) { // Grade 1: 1 in 3 chance of Common NFT, No Rare
            // Common, 1 in 3 chance
            if (getRandomInt(2, seed, 0) == 0) {
                return (1, false);
            }
        } else if (grade == 2) { // Grade 2: 0 to 1 Common NFTs, 1 in grade2RareChance Chance of Rare
            // Rare
            if (getRandomInt(grade2RareChance, seed, 0) == 0) {
                return (0, true);
            }
            // Common
            return (getRandomInt(1, seed, 1), false);
        } else if (grade == 3) { // Grade 2: 0 to 2 Common NFTs, 1 in grade3RareChance Chance of Rare
            // Rare
            if (getRandomInt(grade3RareChance, seed, 0) == 0) {
                return (0, true);
            }
            // Common
            return (getRandomInt(2, seed, 1), false);

        } else if (grade == 4) { // Grade 2: 1 to 3 Common NFTs, 1 in grade4RareChance Chance of Rare
            // Rare
            if (getRandomInt(grade4RareChance, seed, 0) == 0) {
                return (0, true);
            }
            // Common
            return (getRandomInt(2, seed, 1) + 1, false);
        }
        return (0, false);
    }

    function assignNFTs(uint8 numCommon, bool getRare, uint256 seed) private {
        uint8 nonce = 10;
        require(numCommon <= 3, "Too many common NFTs generated");
        if (getRare) {
            nonce +=1;
            // Mint Rare NFT
            uint8 number = getRandomInt(2, seed, nonce) + 5; // 0-2 + 5 = 5-7
            rewardNFT.mint(msg.sender, season, number);
            createdCards[number] += 1;
            emit NFTAwarded(msg.sender, season, number, true);
            return;
        }
        for (uint8 i = 0 ; i < numCommon; i++) {
            nonce += 1;
            // Mint Common NFT
            uint8 number = getRandomInt(3, seed, nonce) + 1; // 0-3 + 1 = 1-4
            rewardNFT.mint(msg.sender, season, number);
            createdCards[number] += 1;
            emit NFTAwarded(msg.sender, season, number, false);
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
        createdCards[0] += 1;
        emit LegendaryForged(msg.sender, cardSet);
    }

    function openPool() private {
        require(rewardPools[season].open == false, "Pool already open");
        require(address(this).balance >= rewardPools[season].balance, "Insufficient funds to open pool");
        require(rewardPools[season].balance > 0, "No funds in pool");
        rewardPools[season].open = true;
        // The rare that has been issued in the smallest number
        uint256 rarestRare = createdCards[5];
        if (createdCards[6] < rarestRare) {
            rarestRare = createdCards[6];
        }
        if (createdCards[7] < rarestRare) {
            rarestRare = createdCards[7];
        }
        if (rarestRare == 0) { // No rares have been issued
            rarestRare = 1;
        }
        // the number of rarest rare issued is the max number of legendaries possible
        rewardPools[season].remainingClaims = rarestRare;
        // Get BNB per claim
        rewardPools[season].rewardPerNFT = rewardPools[season].balance / rewardPools[season].remainingClaims;
        emit PoolOpened(season, rewardPools[season].remainingClaims, rewardPools[season].balance, rewardPools[season].rewardPerNFT);
    }

    function claimLegendaryReward(uint256 nftId, uint16 rewardSeason) public {
        require(rewardPools[rewardSeason].open == true, "Reward claims are not yet open for this season");
        require(rewardNFT.ownerOf(nftId) == msg.sender, "Sender does not own the NFT");
        (uint16 cardSet, uint8 num) = rewardNFT.metadataOf(nftId);
        require(num == 0, "NFT is not of Legendary Quality");
        require(cardSet <= rewardSeason, "NFT Season must be earlier than or equal to reward season");
        require(rewardPools[rewardSeason].nftsClaimed[nftId] == false, "NFT Has been claimed for the reward season");
        rewardPools[rewardSeason].nftsClaimed[nftId] = true; // Reward claimed for this NFT

        require(rewardPools[rewardSeason].remainingClaims >= 1, "No claims remain to be made");
        require(rewardPools[rewardSeason].rewardPerNFT >= rewardPools[rewardSeason].balance, "Pool insolvent");
        rewardPools[rewardSeason].remainingClaims -= 1;
        rewardPools[rewardSeason].balance -= rewardPools[rewardSeason].rewardPerNFT;
        payable(msg.sender).transfer(rewardPools[rewardSeason].rewardPerNFT);
        emit LegendaryRewardClaimed(rewardSeason, season, nftId, cardSet);
    }

    function transferPoolFunds(uint16 from) public onlyOwner {
        require(rewardPools[from].open == true, "Pool to transfer from is closed");
        require(open == true, "Season must be opened");
        require(season > from, "Pool cannot be current season");
        require(rewardPools[from].balance > 0, "Pool balance is zero");
        rewardPools[from].open = false;
        emit PoolClosedAndFundsTransferred(from, season, rewardPools[from].balance);
        rewardPools[season].balance += rewardPools[from].balance;
        rewardPools[from].balance = 0;
    }
    
    function setThresholds(address teamAddress, uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4) public onlyOwner {
        thresholds[teamAddress] = Thresholds({
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
        path[0] = players[msg.sender].team;
        path[1] = pancakeSwapRouter.WETH();
        IBEP20 teamToken = IBEP20(players[msg.sender].team);
        teamToken.approve(address(pancakeSwapRouter), tokenAmount*2);
        
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
        path[1] = players[msg.sender].team;

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
        path[1] = players[msg.sender].team;

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
        createdCards[number] += 1;
    }
}