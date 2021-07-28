
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// File: @uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol

pragma solidity >=0.6.2;


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface IBEP20 {
    function burn(uint256 amount) external  returns (bool);
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface boosterNFT {
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

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

contract piggyGame  is Ownable {
    using Address for address;
   
   
   // reward NFT address
   boosterNFT public _boosterNFT;
   
    // game pool fund (default 5%)
    uint16 public gamePoolFund = 5;
    address gamePoolFundAddress;
    
    //contract operation
    address  public _operator;
   
    
    // token  grade * 10**9 because that the default piggy decimal
    uint256  public commonThreshold = 1 *  10**6  * 10**9;
    uint256 public  rareThreshold = 10 * 10**6 *10**9;
    uint256 public  legendaryThreshold = 100 * 10**6  *10**9; 
    
    
    // chances per grade based on threshold
    uint256  public commonGradeChance = 2;
    uint256 public rareGradeChance = 300;
    uint256 public legendaryGradeChance = 500;
    
    
    //chances ranges from 1 - 1000 where 1 = 0.1 and 1000 == 10
    uint256  public minChance = 1;
    uint256  public maxChance =1000;
    
    //ease level 
    //degree of ease of prediction
    uint256  easelevel = 100;
    
    
    //rewardNFT IDS
    uint256 public constant COMMON = 0;
    uint256 public constant RARE = 1;
    uint256 public constant LEGENDARY = 2;
   
    
    
    // reroll _params
    //thresholds
    
    uint256  public commonRerollThreshold = 10;
    uint256  public rareRerollThreshold = 10;
    
    //chances
    
    uint256  public commonRerollChance = 11;
    uint256  public rareRerollChance = 120;
    
    
    uint256 nonce;
    
    
    // The swap router, modifiable.
    IUniswapV2Router02 public testSwapRouter;
    // The trading pair
    address public testSwapPair;
    
    //piggy token interface 
    IBEP20 private _piggyToken;
    address public piggyAddress;
    //game players structure
    struct boosterLevels {
     uint256   legendary;
     uint256   rare;
     uint256   common;
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
    constructor(IBEP20 piggyToken, boosterNFT _boosterNFTAddress, address _router) {
       _piggyToken = piggyToken ;
       _boosterNFT = _boosterNFTAddress;
       _operator = _msgSender();

       testSwapRouter = IUniswapV2Router02(_router);
       testSwapPair = IUniswapV2Factory(testSwapRouter.factory()).getPair(address(piggyToken), testSwapRouter.WETH());
       require(testSwapPair != address(0), "TEST::updateTestSwapRouter: Invalid pair address.");
    }
    /**
     * @dev Throws if called by any account other than the operator.
     */
    modifier onlyOperator() {
        require( _operator == _msgSender() || owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    //events 
    event  TestSwapRouterUpdated(address indexed operator, address indexed router, address indexed pair);
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
    
    function deposit_(uint256 amount)  public  {
        uint256 tokenbalance =_piggyToken.balanceOf(msg.sender);
        require( tokenbalance >= amount , "insuficient funds");
        require(amount >= commonThreshold ,"Amount below minimun play amount");
         
         //Transfer token to piggyGame contract
        _piggyToken.transferFrom(msg.sender, address(this), amount);
        
        //Transfer to gamePoolFund default 5% 
        uint256 gamePoolFundAmount = (amount * gamePoolFund /100);
        uint256 balance = (amount - (gamePoolFundAmount));

        // send to gamefund
        _piggyToken.transfer(gamePoolFundAddress , gamePoolFundAmount);
      
       
         // capture innitial Eth balance
         uint256 innitialEthBalance = address(this).balance;
         
          
         //_charge 
         
         _charge(balance);
        
         // capture  Eth balance After
         uint256 afterEthBalance = address(this).balance;
         

         require(afterEthBalance > innitialEthBalance , "Nagative Swap occured");
         // capture  Eth received
         
         uint256 EthRecieved = afterEthBalance - innitialEthBalance;
         
         
         //balance of piggy before attack
         uint256 tokenbalanceBeforeAttack =_piggyToken.balanceOf(address(this));
         
         //attack
         //SwapEthForToken
         
         _attack(EthRecieved);
         
           //balance of piggy after attack
          uint256 tokenbalanceAfterAttack =_piggyToken.balanceOf(address(this));
         
            require(tokenbalanceAfterAttack > tokenbalanceBeforeAttack , "Nagative Swap occured");
            
          //token balance to send to user
          balance = tokenbalanceAfterAttack - tokenbalanceBeforeAttack;
         //refund the remaining  remaining tokens;
        _piggyToken.transfer(msg.sender , balance);
         //roll base on amount of token supply 
        
         if(canGetReward(amount)){ 
            
            players[_msgSender()].bootsterPacks += 1;
        
            emit   gamePlayed(_msgSender() , true  ,  easelevel , requiredGuess ,  actualGuess  ,  degreeOfRandomness ,  playchance );
         }
         else{
             emit   gamePlayed(_msgSender() , false ,  easelevel , requiredGuess ,  actualGuess  ,  degreeOfRandomness ,  playchance );
         }
         requiredGuess = 0 ;
         actualGuess  = 0;   
         degreeOfRandomness = 0;
         playchance = 0;
        players[_msgSender()].gamesPlayed += 1;
        
         
    }
    
    // charge function responsible for swapping token to ETH
    function _charge(uint256 amount) private {
        swapTokensForEth(amount);
        emit charged(msg.sender , amount);
    }
    
     // charge function responsible for swapping ETH to token
    function _attack(uint256 EthRecieved) private {
        swapEthForTokens(EthRecieved);
        emit attacked(msg.sender , EthRecieved);
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
    //return available bootsterPack a player has
    function bootsterPackBalanceOf(address _player) public view returns(uint256){
        return players[_player].bootsterPacks;
    }
     //returns total number of games a player has played.
    function totalgamePlayedOf(address _player) public view returns(uint256){
        return players[_player].gamesPlayed;
    }

    /// @dev Swap tokens for eth
    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the testSwap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = piggyAddress;
        path[1] = testSwapRouter.WETH();

        _piggyToken.approve(address(testSwapRouter), tokenAmount*2);
        
        // make the swap
        testSwapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        path[0] = testSwapRouter.WETH();
        path[1] = piggyAddress;

        // make the swap
        testSwapRouter.swapETHForExactTokens{value: EthAmount}(
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
        path[0] = testSwapRouter.WETH();
        path[1] = piggyAddress;

        // make the swap
        testSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: EthAmount}(
           0 ,// get anything we can
            path,
             address(this),
            block.timestamp
        );
    }
    
     // To receive BNB from testSwapRouter when swapping
    receive() external payable {}
 /**
     * @dev Update the swap router.
     * Can only be called by the current operator.
     */
    function updateTestSwapRouter(address _router , address _piggyAddress ) public onlyOperator {
        piggyAddress = _piggyAddress;
        testSwapRouter = IUniswapV2Router02(_router);
        testSwapPair = IUniswapV2Factory(testSwapRouter.factory()).getPair(_piggyAddress , testSwapRouter.WETH());
        require(testSwapPair != address(0), "TEST::updateTestSwapRouter: Invalid pair address.");
        emit TestSwapRouterUpdated(msg.sender, address(testSwapRouter), testSwapPair);
    } 
    function setGamePoolFundAddress(address _gamePoolFundAddress) public onlyOperator {
        gamePoolFundAddress  = _gamePoolFundAddress;
        emit gamePoolFundAddressUpdated(msg.sender , _gamePoolFundAddress);
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
    
    