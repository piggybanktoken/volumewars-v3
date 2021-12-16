// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./IBEP20.sol";
import "./ProxySafeVRFConsumerBase.sol";

// import "./ProxySafeOwnable.sol";

interface IRewardNFT is IERC721 {
    function mint(address to, uint16 set, uint8 number) external;
    function metadataOf(uint256 id) external returns (uint16, uint8);
    function totalCardsOf(uint16 id) external returns (uint8);
    function forgeBurn(uint256 id) external;
    function addSet(uint16 set, uint8 number) external;
}

contract piggyGame is OwnableUpgradeable, ProxySafeVRFConsumerBase  {
    // using Address for address;

    // Reward NFT address
    IRewardNFT public rewardNFT;
    
    // The swap router, modifiable.
    IUniswapV2Router02 public pancakeSwapRouter;

    // Chainlink randomness requests
    struct ChainlinkRequest {
        address requester;
        bool fulfilled;
        uint8[] grades;
        uint256 seed;
    }

    mapping(bytes32 => ChainlinkRequest) requests;

    struct BoosterPack {
        uint256 seed;
        uint8[] grades;
    }

    struct Player {
        uint256 gamesPlayed;
        uint16 season;
        address team;
        uint32 winsBeforeJoin;
        uint256 experience;
        bytes32[] boosterPacks;
        uint256 numBoosterPacks;
        uint8[] unclaimedPacks;
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
    mapping (uint16 => RewardPool) public rewardPools;
    
    // Thresholds for different booster pack grades
    struct Thresholds {
        uint256 grade1;
        uint256 grade2;
        uint256 grade3;
        uint256 grade4;
    }

    Thresholds rewardThresholds;
    
    struct RareChance {
        uint8 grade2;
        uint8 grade3;
        uint8 grade4;
    }
    RareChance public rareChance;

    mapping (uint8 => uint256) public createdCards; // Counter for each card number created
    
    bool public open;

    uint16 public season;
    
    // Chainlink
    bytes32 internal keyHash;
    uint256 internal fee;

    // Dev rewards
    uint256 public devPool;

    uint256 public redeemFee;

    address public feeDestination;

    function initialize(address _piggyToken, address _secondToken, address _router, address _coordinator, address _linkToken, bytes32 _hash, uint256 _fee) external initializer {

        vrfCoordinator = _coordinator;
        LINK = LinkTokenInterface(_linkToken);

        keyHash = _hash;
        fee = _fee;
        pancakeSwapRouter = IUniswapV2Router02(_router);

        rareChance = RareChance({
            grade2: 60, // 1 in 30 Chance
            grade3: 10, // 1 in 10 Chance
            grade4: 5   // 1 in 5 Chance
        });

        feeDestination = msg.sender;
        OwnableUpgradeable.__Ownable_init_unchained();
        redeemFee = 10000000000000000;
        // Loss target: 0.003, 0.01, 0.06, 0.12 BNB
        setThresholds(3 * 10**15, 1*10**16, 6*10**16, 12*10**16);
        addTeam(_piggyToken);

        addTeam(_secondToken);
    }

    event SeasonClose(address indexed owner, uint32 indexed season, address indexed winner);
    event SeasonOpen(address indexed owner, uint32 indexed season);
    event TeamAdded(address indexed owner, address indexed team);
    event JoinedGame(address indexed player, uint256 indexed season, address indexed team);
    event Attack(address indexed player, address indexed team, uint256 amount);
    event ReceivedBoosterPack(address indexed requester, uint256 randomness);
    event BoosterPackOpened(address indexed player, uint8 nonce);
    event NFTAwarded(address indexed player, uint16 indexed set, uint8 indexed number, bool rare);
    event LegendaryForged(address indexed player, uint16 indexed set);
    event ThresholdsSet(address indexed owner, uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4);
    event RareChanceSet(address indexed owner, uint256 grade2, uint256 grade3, uint256 grade4);
    event PoolOpened(uint16 indexed season, uint256 totalClaims, uint256 initialBalance, uint256 rewardPerNFT);
    event LegendaryRewardClaimed(uint16 indexed rewardSeason, uint16 indexed currentSeason, uint256 indexed NFT, uint16 NFTSet);
    event PoolClosedAndFundsTransferred(uint16 indexed poolSeason, uint16 indexed currentSeason, uint256 amount);

    // To receive BNB from pancakeSwapRouter when swapping
    receive() external payable {}

    function getRedeemFee() external view returns (uint256) {
        return redeemFee;
    }
    function isGameOpen() external view returns (bool) {
        return open;
    }
    function currentSeason() external view returns (uint16) {
        return season;
    }
    function balanceOf(address _player) external view returns (uint256) {
        return balances[_player];
    }
    function boosterPackBalanceOf(address _player) external view returns(uint256){
        return players[_player].numBoosterPacks;
    }
    function totalExperienceOf(address _player) external view returns(uint256){
        return players[_player].experience;
    }
    function teamOf(address _player) external view returns(address){
        return players[_player].team;
    }
    function getThresholds() external view returns(uint256, uint256, uint256, uint256) {
        return (rewardThresholds.grade1, rewardThresholds.grade2, rewardThresholds.grade3, rewardThresholds.grade4);
    }
    function hasPlayerJoined(address _player) external view returns(bool) {
        return players[_player].season == season;
    }
    function getRareChances() external view returns(uint8, uint8, uint8) {
        return (rareChance.grade2, rareChance.grade3, rareChance.grade4);
    }
    function teamDamageOf(address teamId) external view returns(uint256) {
        return teams[teamId].damagePoints;
    }
    function teamWinsOf(address teamId) external view returns(uint32) {
        return teams[teamId].wins;
    }
    function getActiveTeams() external view returns(address[] memory) {
        return activeTeams;
    }
    function playerWins(address _player) external view returns(uint32){
        address team = players[_player].team;
        uint32 winsBeforeJoin = players[_player].winsBeforeJoin;
        require(teams[team].wins >= winsBeforeJoin, "Wins before join higher than total wins");
        return teams[team].wins - winsBeforeJoin;
    }
    function tokenInfo(address teamAddress) external view returns (uint8, string memory, string memory) {
        return (IBEP20(teamAddress).decimals(), IBEP20(teamAddress).symbol(), IBEP20(teamAddress).name());
    }

    function tokenBalanceOf(address player) external view returns (uint256) {
        address teamAddress = players[player].team;
        return IBEP20(teamAddress).balanceOf(player);
    }
    function unclaimedBoosterPacksOf(address player) external view returns (uint256) {
        return players[player].unclaimedPacks.length;
    }

    function isNFTRedeemable(uint256 nftId, uint16 poolId) external view returns (bool) {
        return rewardPools[poolId].nftsClaimed[nftId] == false;
    }
    function setOpen(bool isOpen) external onlyOwner {
        open = isOpen;
    }
    function setSeason(uint16 _season) external onlyOwner {
        season = _season;
    }
    function openSeason() external onlyOwner {
        require(open == false, "Season Open");
        season += 1;
        open = true;
        rewardNFT.addSet(season, 7);
        emit SeasonOpen(msg.sender, season);
    }
    function closeSeason() external onlyOwner {
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
    }

    function addTeam(address teamTokenAddress) public onlyOwner {
        teams[teamTokenAddress].enabled = true;
        activeTeams.push(teamTokenAddress);
        emit TeamAdded(msg.sender, teamTokenAddress);
    }
    function withdrawAllDevETH(address payable _to) external {
        require(devPool > 0, "No funds");
        require(msg.sender == feeDestination);
        uint256 withdrawAmount = devPool;
        devPool = 0;
        _to.transfer(withdrawAmount);
    }
    function changeFeeDestination(address newFeeDestination) external {
        require(msg.sender == feeDestination);
        feeDestination = newFeeDestination;
    }
    function withdrawLink(address payable _to, uint256 amount) external onlyOwner {
        LINK.transfer(_to, amount);
    }
    function setFeesAndJoinReq(uint256 newRedeemFee) external onlyOwner {
        redeemFee = newRedeemFee;
    }
    function setTeamEnabled(address teamAddress, bool enabled) external onlyOwner {
        teams[teamAddress].enabled = enabled;
    }
    /**
     * @dev Update the swap router.
     * Can only be called by the current operator.
     */
    function updatePancakeSwapRouter(address _router) external onlyOwner {
        pancakeSwapRouter = IUniswapV2Router02(_router);
    }
    function updateNFTAddress(IRewardNFT _rewardNFTAddress) external onlyOwner {
        rewardNFT = _rewardNFTAddress;
    }

    function join(address teamTokenAddress) external {
        require(open, "Game closed");
        require(players[msg.sender].team == address(0));
        require(teams[teamTokenAddress].enabled == true, "Team invalid");
        players[msg.sender].team = teamTokenAddress;
        emit JoinedGame(msg.sender, season, teamTokenAddress);
    }

    function attack(address team) external payable {
        require(open, "Game closed");
        require(season > 0, "Season 0");
        require(msg.value > 0, "No BNB");
        require(players[msg.sender].team != team, "Friendly Fire");
        require(players[msg.sender].team != address(0), "Not on a team");
        require(teams[team].enabled, "Team invalid");
        require(teams[players[msg.sender].team].enabled, "Own Team disabled");
        
        // Taking fees

        uint256 userDeposit = msg.value; // msg.value: the total deposit

        uint256 feeTaken = userDeposit/2; // fee: the part taken as a fee, 50%
        userDeposit -= userDeposit/2; // userDeposit: the part used for the attack

        devPool += feeTaken/2; // Half of the fee goes to the devs
        feeTaken -= feeTaken/2;

        rewardPools[season].balance += feeTaken; // Half of the fee goes to the rewards pool

        // Attack

        // The team's corresponding token
        IBEP20 teamToken = IBEP20(players[msg.sender].team);
        uint256 initialETHBalance = address(this).balance - userDeposit;
        uint256 initialTokenBalance = teamToken.balanceOf(address(this));
        swapEthForTokens(userDeposit); // Buy tokens for ETH
        uint256 finalTokenBalance = teamToken.balanceOf(address(this));
        require(finalTokenBalance > initialTokenBalance, "No Tokens");
        require(initialETHBalance == address(this).balance, "Contract ETH Balance changed");

        requestReward(msg.value);
        players[msg.sender].gamesPlayed += 1;
        players[msg.sender].experience += msg.value;
        teams[team].damagePoints += msg.value;
        emit Attack(
        msg.sender, 
        team,
        msg.value);
    }

    function getRandomNumber() private returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Insuff. LINK");
        return requestRandomness(keyHash, fee);
    }

    function requestReward(uint256 amount) private {
        if (amount < rewardThresholds.grade1) {
            return;
        }
        if (amount < rewardThresholds.grade2) {
            players[msg.sender].unclaimedPacks.push(1);
        } else if (amount < rewardThresholds.grade3) {
            players[msg.sender].unclaimedPacks.push(2);
        } else if (amount < rewardThresholds.grade4) {
            players[msg.sender].unclaimedPacks.push(3);
        } else if (amount >= rewardThresholds.grade4) {
            players[msg.sender].unclaimedPacks.push(4);
        }
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        if (requests[requestId].fulfilled) {
            return;
        }
        requests[requestId].fulfilled = true;
        requests[requestId].seed = randomness;
        players[requests[requestId].requester].boosterPacks.push(requestId);
        players[requests[requestId].requester].numBoosterPacks += requests[requestId].grades.length;
        emit ReceivedBoosterPack(requests[requestId].requester, randomness);
    }
    function claimBoosterPacks() external payable {
        require(open, "Closed");
        require(players[msg.sender].unclaimedPacks.length > 0, "No booster packs");
        require(msg.value == redeemFee, "Fee required");
        uint256 userDeposit = msg.value;
        devPool += userDeposit/2;
        userDeposit -= userDeposit/2;
        rewardPools[season].balance += userDeposit;
        bytes32 requestId = getRandomNumber();
        requests[requestId].requester = msg.sender;
        requests[requestId].fulfilled = false;
        requests[requestId].grades = players[msg.sender].unclaimedPacks;
        // Reset player unclaimed packs
        players[msg.sender].unclaimedPacks = new uint8[](0);
    }
    function unpackBoosterPack() external {
        require(open, "Closed");
        uint numPacks = players[msg.sender].boosterPacks.length;
        require(numPacks > 0, "No booster packs");
        bytes32 requestId = players[msg.sender].boosterPacks[numPacks-1];
        uint256 seed = requests[requestId].seed;

        uint256 numGrades = requests[requestId].grades.length;
        for (uint256 i = 0; i < numGrades; i++) {
            uint8 grade = requests[requestId].grades[i];
            (uint8 numCommon, bool getRare) = getNumRewards(seed, uint8(i), grade, rareChance.grade2-1, rareChance.grade3-1, rareChance.grade4-1);
            assignNFTs(numCommon, getRare, seed, uint8(i));
            emit BoosterPackOpened(msg.sender, uint8(i));
        }
        players[msg.sender].boosterPacks.pop();
        players[msg.sender].numBoosterPacks -= numGrades;
        delete requests[requestId];
    }

    function getNumRewards(uint256 seed, uint8 nonce, uint8 grade, uint8 grade2RareChance, uint8 grade3RareChance, uint8 grade4RareChance) public pure returns(uint8, bool) { // Common, Rare
        require(grade > 0, "G. too low");
        require(grade <= 4, "G. too high");
        if (grade == 1) { // Grade 1: 1 in 3 chance of Common NFT, No Rare
            // Common, 1 in 3 chance
            if (getRandomInt(2, seed, nonce) == 0) {
                return (1, false);
            }
        } else if (grade == 2) { // Grade 2: 0 to 1 Common NFTs, 1 in grade2RareChance Chance of Rare
            // Rare
            if (getRandomInt(grade2RareChance, seed, nonce) == 0) {
                return (0, true);
            }
            nonce +=1;
            // Common
            return (getRandomInt(1, seed, nonce), false);
        } else if (grade == 3) { // Grade 2: 0 to 2 Common NFTs, 1 in grade3RareChance Chance of Rare
            // Rare
            if (getRandomInt(grade3RareChance, seed, nonce) == 0) {
                return (0, true);
            }
            nonce +=1;
            // Common
            return (getRandomInt(2, seed, nonce), false);

        } else if (grade == 4) { // Grade 2: 1 to 3 Common NFTs, 1 in grade4RareChance Chance of Rare
            // Rare
            if (getRandomInt(grade4RareChance, seed, nonce) == 0) {
                return (0, true);
            }
            nonce +=1;
            // Common
            return (getRandomInt(2, seed, nonce) + 1, false);
        }
        return (0, false);
    }

    function assignNFTs(uint8 numCommon, bool getRare, uint256 seed, uint8 nonceIncrement) private {
        uint8 nonce = 64 + nonceIncrement;
        require(numCommon <= 3, "Too many commons");
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

    function forgeLegendary(uint256[] calldata ids) external {
        (uint16 cardSet, uint8 _number) = rewardNFT.metadataOf(ids[0]);
        require(_number == 1, "First card != 1");
        uint8 totalCards = rewardNFT.totalCardsOf(cardSet);
        require(totalCards == ids.length, "Wrong n of cards");

        for (uint8 i = 0 ; i < totalCards; i++) {
            require(rewardNFT.ownerOf(ids[i]) == msg.sender, "Not NFT owner");
            (uint16 set, uint8 number) = rewardNFT.metadataOf(ids[i]);
            require(set == cardSet, "Wrong set");
            require(number == (i+1), "Wrong number/order"); // Cards are from 1 to totalCards, i is from 0 to totalCards - 1
            rewardNFT.forgeBurn(ids[i]); // Burn NFT
        }
        rewardNFT.mint(msg.sender, cardSet, 0); // Card 0 of set is Legendary
        createdCards[0] += 1;
        emit LegendaryForged(msg.sender, cardSet);
    }

    function openPool() private {
        require(rewardPools[season].open == false, "Pool is open");
        require(address(this).balance >= rewardPools[season].balance, "Insuff. funds to open");
        require(rewardPools[season].balance > 0, "No balance");
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

    function claimLegendaryReward(uint256 nftId, uint16 rewardSeason) external {
        require(rewardPools[rewardSeason].open == true, "Claims not open");
        require(rewardNFT.ownerOf(nftId) == msg.sender, "Not NFT owner");
        (uint16 cardSet, uint8 num) = rewardNFT.metadataOf(nftId);
        require(num == 0, "Not Legendary");
        require(cardSet <= rewardSeason, "NFT Season not <= reward season");
        require(rewardPools[rewardSeason].nftsClaimed[nftId] == false, "NFT claimed for season");
        rewardPools[rewardSeason].nftsClaimed[nftId] = true; // Reward claimed for this NFT

        require(rewardPools[rewardSeason].remainingClaims >= 1, "No claims left");
        require(rewardPools[rewardSeason].rewardPerNFT <= rewardPools[rewardSeason].balance, "Insolvent");
        rewardPools[rewardSeason].remainingClaims -= 1;
        rewardPools[rewardSeason].balance -= rewardPools[rewardSeason].rewardPerNFT;
        payable(msg.sender).transfer(rewardPools[rewardSeason].rewardPerNFT);
        emit LegendaryRewardClaimed(rewardSeason, season, nftId, cardSet);
    }

    function transferPoolFunds(uint16 from) external onlyOwner {
        require(rewardPools[from].open == true, "From is closed");
        require(open == true, "Season closed");
        require(season > from, "Pool is current");
        require(rewardPools[from].balance > 0, "Pool is zero");
        rewardPools[from].open = false;
        emit PoolClosedAndFundsTransferred(from, season, rewardPools[from].balance);
        rewardPools[season].balance += rewardPools[from].balance;
        rewardPools[from].balance = 0;
    }
    
    function setThresholds(uint256 grade1, uint256 grade2, uint256 grade3, uint256 grade4) public onlyOwner {
        rewardThresholds = Thresholds({
            grade1: grade1, 
            grade2: grade2,
            grade3: grade3,
            grade4: grade4
        });
        emit ThresholdsSet(msg.sender, grade1, grade2, grade3, grade4);
    }

    function setRareChance(uint8 grade2, uint8 grade3, uint8 grade4) external onlyOwner {
        rareChance = RareChance({
            grade2: grade2,
            grade3: grade3,
            grade4: grade4
        });
        emit RareChanceSet(msg.sender, grade2, grade3, grade4);
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

    // function mintNFT(address to, uint16 set, uint8 number) external onlyOwner {
    //     rewardNFT.mint(to, set, number);
    //     createdCards[number] += 1;
    // }
}