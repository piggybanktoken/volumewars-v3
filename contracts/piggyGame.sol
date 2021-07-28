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

interface IBoosterNFT is IERC721 {
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
    IBoosterNFT public _boosterNFT;
    
    // Contract operation
    address public _operator;
   
    
    // Token grade * 10**9 because that the default piggy decimal
    uint256 public commonThreshold = 1 *  10**6  * 10**9;
    uint256 public rareThreshold = 10 * 10**6 *10**9;
    uint256 public legendaryThreshold = 100 * 10**6  *10**9; 
    
    
    // Chances per grade based on threshold
    uint256 public commonGradeChance = 2;
    uint256 public rareGradeChance = 300;
    uint256 public legendaryGradeChance = 500;
    
    
    // Chances ranges from 1 - 1000 where 1 = 0.1 and 1000 == 10
    uint256 public minChance = 1;
    uint256 public maxChance =1000;
    
    //ease level 
    //degree of ease of prediction
    uint256 easelevel = 100;
    
    
    //rewardNFT IDS
    uint256 public constant COMMON = 0;
    uint256 public constant RARE = 1;
    uint256 public constant LEGENDARY = 2;
   
    
    
    // reroll _params
    //thresholds
    
    uint256 public commonRerollThreshold = 10;
    uint256 public rareRerollThreshold = 10;
    
    //chances
    
    uint256 public commonRerollChance = 11;
    uint256 public rareRerollChance = 120;
    
    
    uint256 nonce;
    
    
    // The swap router, modifiable.
    IUniswapV2Router02 public pancakeSwapRouter;
    // The trading pair
    address public pancakeSwapPair;
    
    //piggy token interface
    IBEP20 private _piggyToken;
    address public piggyAddress;

    //game players structure
    struct boosterLevels {
     uint256 legendary;
     uint256 rare;
     uint256 common;
    }
    struct chances {
        uint256 legendary;
        uint256 rare;
        uint256 common;
    }

    struct player {
        uint256 gamesPlayed;
        uint256 bootsterPacks;
        uint256 season;
        uint256 team;
        uint256 experience;
    }
    // Players
    mapping(address => player) public players;

    // User Piggy Balance
    mapping(address => uint256) public balances;
    
    uint256 public season;

    struct Team {
        bool enabled;
        uint256 wins;
        uint256 damagePoints;
    }

    // Teams
    mapping(uint256 => Team) public teams;

    uint256 latestTeam = 0;

    uint256 public joinFee = 100000000000000000; // 0.1 ETH
    bool public open = false;

    chances public defaultChances; 
    //internals
    uint256 private requiredGuess;
    uint256 private actualGuess;
    uint256 private degreeOfRandomness ; 
    uint256 private playchance;

    //setup the piggyGame contract
    //@dev innitializes the owner and _operator
    //@_params piggyAddress is the address of the piggy token
    constructor(IBEP20 piggyToken, IBoosterNFT _boosterNFTAddress, address _router) {
       _piggyToken = piggyToken ;
       _boosterNFT = _boosterNFTAddress;
       _operator = _msgSender();

       pancakeSwapRouter = IUniswapV2Router02(_router);
       pancakeSwapPair = IUniswapV2Factory(pancakeSwapRouter.factory()).getPair(address(piggyToken), pancakeSwapRouter.WETH());
       require(pancakeSwapPair != address(0), "TEST::updatepancakeSwapRouter: Invalid pair address.");
    }
    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require( _operator == _msgSender() || owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    //events 
    event  pancakeSwapRouterUpdated(address indexed operator, address indexed router, address indexed pair);
    event  OperatorTransferred(address indexed previousOperator, address indexed newOperator);
    event  gamePoolFundAddressUpdated(address indexed operator , address indexed gameFundAddress);
    event  amountThresholdUpdated(address indexed operator , uint256  commonThreshold ,  uint256  rareThreshold ,  uint256  legendaryThreshold);
    event  defaultGameChanceUpdated(address indexed operator , uint256  commonChance ,  uint256  rareChance ,  uint256  legendaryChance);
    event  rerollThresholdUpdated(address indexed operator , uint256  previous_commonRerollThreshold ,  uint256 new_commonRerollThreshold , uint256  previous_rareRerollThreshold ,  uint256 new_rareRerollThreshold );
    event  rerollChancesUpdated(address indexed operator , uint256  previous_commonRerollChance ,  uint256 new_commonRerollChance , uint256  previous_rareRerollChance ,  uint256 new_rareRerollChance );
    event  gameEaseLevelUpdated(address indexed operator , uint256 _easelevel);
    event  charged(address indexed player, uint256 amount);
    event  attacked(address indexed player, uint256 amount);
    event  rewardEarned(address indexed player , uint256 rewardID);
    event  gamePlayed(address indexed player , bool earnedReward , uint256 easelevel , uint256 requiredGuess , uint256 actualGuess  , uint256 degreeOfRandomness , uint256 playchance );

    // To receive BNB from pancakeSwapRouter when swapping
    receive() external payable {}
    /**
    * @dev Returns the address of the current operator.
    */
    function operator() public view returns (address) {
        return _operator;
    }
    function balanceOf(address _player) public view returns (uint256) {
        return balances[_player];
    }
    function totalBalance() public view returns (uint256) {
        return _piggyToken.balanceOf(address(this));
    }

    //return available bootsterPack a player has
    function bootsterPackBalanceOf(address _player) public view returns(uint256){
        return players[_player].bootsterPacks;
    }
    // Returns total number of games a player has played.
    function totalgamePlayedOf(address _player) public view returns(uint256){
        return players[_player].gamesPlayed;
    }
    function setOpen(bool isOpen) public onlyOperator {
        open = isOpen;
    }
    function setSeason(uint256 _season) public onlyOperator {
        season = _season;
    }
    function addTeam() public onlyOperator {
        latestTeam += 1;
        teams[latestTeam].enabled = true;
    }
    function withdrawETH(uint256 amount, address payable _to) public onlyOperator {
        _to.transfer(amount);
    }
    function withdrawAllETH(address payable _to) public onlyOperator {
        _to.transfer(address(this).balance);
    }
    function setJoinFee(uint256 fee) public onlyOperator {
        joinFee = fee;
    }
    /**
     * @dev Update the swap router.
     * Can only be called by the current operator.
     */
    function updatePancakeSwapRouter(address _router , address _piggyAddress ) public onlyOperator {
        piggyAddress = _piggyAddress;
        pancakeSwapRouter = IUniswapV2Router02(_router);
        pancakeSwapPair = IUniswapV2Factory(pancakeSwapRouter.factory()).getPair(_piggyAddress , pancakeSwapRouter.WETH());
        require(pancakeSwapPair != address(0), "TEST::updatepancakeSwapRouter: Invalid pair address.");
        emit pancakeSwapRouterUpdated(msg.sender, address(pancakeSwapRouter), pancakeSwapPair);
    }
    /**
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOperator(address newOperator) public  onlyOperator {
        require(newOperator != address(0), " new operator is the zero address");
        emit OperatorTransferred(_operator, newOperator);
        _operator = newOperator;
    }
    function join() public payable {
        require(open, "Game is closed");
        require(msg.value == joinFee, "BNB provided must equal the fee");
        require(players[msg.sender].season != season, "Player has already joined season");
        players[msg.sender].season = season;
        if (players[msg.sender].team == 0) {
            players[msg.sender].team = 1; // TODO: Random team
        }
    }
    function buyTokens(uint256 minTokens) public payable {
        require(open, "Game is closed");
        require(msg.value > 0, "No BNB provided");
        uint256 initialTokenBalance = _piggyToken.balanceOf(address(this));
        swapEthForExactTokens(msg.value, minTokens);
        uint256 finalTokenBalance = _piggyToken.balanceOf(address(this));
        uint256 tokensReceived = finalTokenBalance - initialTokenBalance;
        require(tokensReceived > 0, "No Tokens provided");
        balances[msg.sender] = balances[msg.sender] + tokensReceived;
    }
    function deposit(uint256 amount) public {
        require(open, "Game is closed");
        uint256 tokenbalance =_piggyToken.balanceOf(msg.sender);
        require(tokenbalance >= amount, "Insufficient funds");
        require(amount >= commonThreshold, "Amount below minimun play amount");
        uint256 previousBalance = _piggyToken.balanceOf(address(this));
        // Transfer tokens to the game contract
        _piggyToken.transferFrom(msg.sender, address(this), amount);
        uint256 currentBalance = _piggyToken.balanceOf(address(this));
        require(currentBalance - previousBalance > 0, "Negative Balance Increase");
        balances[msg.sender] = balances[msg.sender] + (currentBalance - previousBalance);
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient token balance");
        uint256 previousBalance = _piggyToken.balanceOf(address(this));
        _piggyToken.transfer(msg.sender, amount);
        balances[msg.sender] = balances[msg.sender] - amount;
        uint256 currentBalance = _piggyToken.balanceOf(address(this));
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
        uint256 initialBalance = _piggyToken.balanceOf(address(this));
        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amount);
        emit charged(msg.sender, amount);
        balances[msg.sender] = balances[msg.sender] - amount;

        uint256 afterBalance = _piggyToken.balanceOf(address(this));
        uint256 afterETHBalance = address(this).balance;
        require((initialBalance - afterBalance) <= amount, "Contract balance decrease greater than amount"); // Fails on ==, why?
        uint256 ETHReceived = afterETHBalance - initialETHBalance;
        require(ETHReceived > 0, "Negative BNB from selling tokens");

        swapEthForTokens(ETHReceived);
        emit attacked(msg.sender, ETHReceived);

        uint256 finalETHBalance = address(this).balance;
        uint256 finalBalance = _piggyToken.balanceOf(address(this));
        require(finalETHBalance >= initialETHBalance, "BNB Balance of contract decreased");
        uint256 tokensReceived = finalBalance - afterBalance;
        require(tokensReceived > 0, "Tokens lost in purchase");
        require(tokensReceived < amount, "Tokens increased after charge and attack");
        balances[msg.sender] = balances[msg.sender] + tokensReceived;
        if (canGetReward(amount)) {
            players[msg.sender].bootsterPacks += 1;
            emit gamePlayed(msg.sender, true,  easelevel, requiredGuess,  actualGuess,  degreeOfRandomness,  playchance);
        } else {
            emit gamePlayed(msg.sender, false, easelevel, requiredGuess, actualGuess, degreeOfRandomness, playchance);
        }
        requiredGuess = 0 ;
        actualGuess  = 0;   
        degreeOfRandomness = 0;
        playchance = 0;
        players[msg.sender].gamesPlayed += 1;
        players[msg.sender].experience += amount;
        teams[players[msg.sender].team].damagePoints += amount;
    }

    /// @dev Swap tokens for eth
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the testSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = piggyAddress;
        path[1] = pancakeSwapRouter.WETH();

        _piggyToken.approve(address(pancakeSwapRouter), tokenAmount*2);
        
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

    function unPack(uint256 amount) public {
         player storage gameplayer = players[msg.sender];
         require(amount > 0  && amount >= gameplayer.bootsterPacks , "Insuficient bootsterPacks");
         gameplayer.bootsterPacks -= amount ;
        for (uint256 i = 0 ; i < amount ; i++){
            getReward();
        }
    }
    
    //approval for 10 COMMON must be called for this contract on the NFT BOOSTER contract to able to successfully exacute this function.
    function reRollCommon() public {
        require(_boosterNFT.balanceOf(_msgSender(),COMMON) >= commonRerollThreshold , "Insuficient COMMON Reroll balance, 1O common required! " );
          _boosterNFT.burn(_msgSender() , COMMON , commonRerollThreshold);
          if(attemptRoll(commonRerollChance)){
              _boosterNFT.mintReward(_msgSender() , LEGENDARY);
              emit rewardEarned(_msgSender() , LEGENDARY);
          }
          
    }
     //approval for 10 RARE must be called for this contract on the NFT BOOSTER contract to able to successfully exacute this function.
    function reRollRare() public {
        require(_boosterNFT.balanceOf(_msgSender(),RARE) >= rareRerollThreshold , "Insuficient RARE Reroll balance, 1O rare required! " );
          _boosterNFT.burn(_msgSender() , RARE , rareRerollThreshold);
          if(attemptRoll(rareRerollChance)){
              _boosterNFT.mintReward(_msgSender() , LEGENDARY);
              emit rewardEarned(_msgSender() , LEGENDARY);
          }
          
    }
    function getReward() internal returns(bool){
      chances storage playerchance =  defaultChances;
     
      for (uint256 i = 0 ; i < 3 ; i++){
          // atempt legendary
      
      if(attemptRoll(playerchance.legendary)){
        _boosterNFT.mintReward(_msgSender() , LEGENDARY);
        emit rewardEarned(_msgSender() , LEGENDARY);
      }
      else if(attemptRoll(playerchance.rare)){
        _boosterNFT.mintReward(_msgSender() , RARE); 
         emit rewardEarned(_msgSender() , RARE);
      }
     else {
       _boosterNFT.mintReward(_msgSender() , COMMON); 
       emit rewardEarned(_msgSender() , COMMON);
       
     }
      }
      return true;
      
    }
    // this function rolls based on the amount of token sent 
    function canGetReward(uint256 amount ) internal returns(bool)  {
        if(amount >= commonThreshold &&  amount < rareThreshold ){
            playchance = commonGradeChance;
            return attemptRoll(commonGradeChance);
        }else  if(amount >= rareThreshold && amount < legendaryThreshold){
            playchance = rareGradeChance;
            return attemptRoll(rareGradeChance);
        }else if (amount >= legendaryThreshold){
            playchance = legendaryGradeChance;
            return attemptRoll(legendaryGradeChance);
        }
        else {
            playchance = 0;
            return false;
        }
        
    }
    
    function attemptRoll(uint256 chance) public  returns (bool) {
        
         // get degree of random ness
         
      uint256  degree = getDegreeFromChance(chance);
      degreeOfRandomness = degree;
      uint256  target = random(degree);
      requiredGuess = target;
      uint256 userRoll = random(degree);
      actualGuess = userRoll;
      if(userRoll == target){
          return true;
      }
         return false;
    }
    
    function getDegreeFromChance(uint chance ) internal view returns (uint256 ){
        require(chance <= maxChance , "Invalid chance value");
        if(((maxChance - chance) <= 0) && (chance <= maxChance)){
            return maxChance/10;
        }
       else if(maxChance - chance >= easelevel){
           return (maxChance - chance) / easelevel; 
        }
        return maxChance - chance;
    }
    function random(uint256 rdegree) internal returns (uint256) {
    uint256 randomnumber = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % rdegree;
    nonce++;
    return randomnumber;
    
    
    }
    // @dev  modify ease level ranges from 10 - 100;
    // @_param easelevel
     function setEaseLevel(uint256 _easelevel) public onlyOperator{
         require( inRange(10 , 200  , _easelevel), "Ease level out of range");
            easelevel = _easelevel;
            emit gameEaseLevelUpdated(msg.sender , _easelevel);
    }
    // adjusting the default chances of getting a common a rar and a lengendary
    //@_param_common chances for common
    //@_param_rare chances for rare
    //@_param_legendary chances for legendary
    function setDefaultChances(uint256 commonChance   , uint256 rareChance  , uint256 legendaryChance  ) public onlyOperator {
        require(
            inRange(1 , 1000 ,commonChance ) &&
             inRange(1 , 1000 , rareChance ) &&
              inRange(1 , 1000 , legendaryChance ) , "Values out of range");
              
             defaultChances.legendary = legendaryChance ;
             defaultChances.rare = rareChance ;
             defaultChances.common = commonChance ;
             emit defaultGameChanceUpdated(msg.sender ,commonChance , rareChance , legendaryChance );
        
    }
    //set play Amount threshold
    // play Amount threshold is the minimun of piggy that  can be sent for an increase in chance of getting booster pack;
 
    function setAmountThreshold(uint256 _commonThreshold ,uint256 _rareThreshold, uint256 _legendaryThreshold ) public onlyOperator {
      
             commonThreshold = _commonThreshold;
             rareThreshold = _rareThreshold;
             legendaryThreshold = _legendaryThreshold;
             
             emit amountThresholdUpdated(msg.sender , _commonThreshold , _rareThreshold ,_legendaryThreshold);
    }
    
    //set NFT reroll/ burn threshold
    // reroll threshold is the amount of NFT to be burnt to give a certain chance of winning a legendary;
    
    function setRerollThreshold(uint256 _commonRerollThreshold ,uint256 _rareRerollThreshold ) public onlyOperator {
      
           emit rerollThresholdUpdated(msg.sender ,commonRerollThreshold ,  _commonRerollThreshold , rareRerollThreshold ,_rareRerollThreshold);
            commonRerollThreshold = _commonRerollThreshold;
            rareRerollThreshold = _rareRerollThreshold;
             
             
    }
     //set NFT reroll/ Chances
    // reroll Chance is the Chance getting a legendary on a roll;
    //value range from 1 - 1000 for value 0.1 - 100
    
    function setRerollChance(uint256 _commonRerollChance ,uint256 _rareRerollChance ) public onlyOperator {
           require(
               inRange(1 , 1000 ,_commonRerollChance ) && 
               inRange(1 , 1000 ,_rareRerollChance) , "Values out of range");      
           emit rerollChancesUpdated(msg.sender ,commonRerollChance ,  _commonRerollChance , rareRerollChance , _rareRerollChance);
            commonRerollChance = _commonRerollChance;
            rareRerollChance = _rareRerollChance;
             
    }
    
    function inRange(uint256 lowerLimit  , uint256  upperLimit, uint256 value) internal pure returns(bool){
        if(value >= lowerLimit && value <= upperLimit) {
            return true;
        }
        return false;
    }
     
}