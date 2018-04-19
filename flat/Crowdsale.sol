pragma solidity ^0.4.13;

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract HasManager {
  address public manager;

  modifier onlyManager {
    require(msg.sender == manager);
    _;
  }

  function transferManager(address _newManager) public onlyManager() {
    require(_newManager != address(0));
    manager = _newManager;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Crowdsaled is Ownable {
        address public crowdsaleContract = address(0);
        function Crowdsaled() public {
        }

        modifier onlyCrowdsale{
          require(msg.sender == crowdsaleContract);
          _;
        }

        modifier onlyCrowdsaleOrOwner {
          require((msg.sender == crowdsaleContract) || (msg.sender == owner));
          _;
        }

        function setCrowdsale(address crowdsale) public onlyOwner() {
                crowdsaleContract = crowdsale;
        }
}

contract WithBonusPeriods is Ownable {
  event DEBUG(uint256 code);
  uint256 constant INVALID_FROM_TIMESTAMP = 1000000000000;
  uint256 constant INFINITY_TO_TIMESTAMP= 1000000000000;
  struct BonusPeriod {
    uint256 fromTimestamp;
    uint256 toTimestamp;
    uint256 bonusNumerator;
    uint256 bonusDenominator;
  }

  BonusPeriod[] public bonusPeriods;
  BonusPeriod currentBonusPeriod;

  function WithBonusPeriods() public {
      initBonuses();
  }

  function BonusPeriodsCount() public view returns (uint8) {
    return uint8(bonusPeriods.length);
  }

  function BonusPeriodFor(uint256 timestamp) public view returns (bool ongoing, uint256 from, uint256 to, uint256 num, uint256 den) {
    for(uint i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= timestamp && bonusPeriods[i].toTimestamp >= timestamp)
        return (true, bonusPeriods[i].fromTimestamp, bonusPeriods[i].toTimestamp, bonusPeriods[i].bonusNumerator,
          bonusPeriods[i].bonusDenominator);
    return (false, 0, 0, 0, 0);
  }

  /*function removeBonusPeriod(uint index) public onlyOwner {
    require(index >=0 && bonusPeriods.length > index);
    for(uint i = index + 1; i < bonusPeriods.length; i++)
      bonusPeriods[i - 1] = bonusPeriods[i];
    bonusPeriods.length--;
  }

  function addBonusPeriod(uint256 fromTimestamp, uint256 toTimestamp, uint bonusNumerator, uint bonusDenominator) public onlyOwner {
      require(fromTimestamp <= toTimestamp);
      require(bonusNumerator >= 0 && bonusDenominator > 0);
      require(bonusPeriods.length < 255);

      bonusPeriods.push(BonusPeriod(fromTimestamp, toTimestamp, bonusNumerator, bonusDenominator));
  }*/

  function initBonusPeriod(uint256 from, uint256 to, uint256 num, uint256 den) internal  {
    bonusPeriods.push(BonusPeriod(from, to, num, den));
  }

  function initBonuses() internal {
    //test bonuses, real ones will be added later here
      initBonusPeriod(block.timestamp, block.timestamp + 3600 * 24, 3, 10);
      initBonusPeriod(block.timestamp + 3600 * 24 + 1, block.timestamp + 3600 * 48, 1, 10);
  }

  function updateCurrentBonusPeriod() internal  {
    if (currentBonusPeriod.fromTimestamp <= block.timestamp
      && currentBonusPeriod.toTimestamp >= block.timestamp)
      return;

    currentBonusPeriod.fromTimestamp = INVALID_FROM_TIMESTAMP;

    for(uint i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= block.timestamp && bonusPeriods[i].toTimestamp >= block.timestamp) {
        currentBonusPeriod = bonusPeriods[i];
        return;
      }
  }
}

contract ICrowdsaleProcessor is Ownable, HasManager {
  modifier whenCrowdsaleAlive() {
    require(isActive());
    _;
  }

  modifier whenCrowdsaleFailed() {
    require(isFailed());
    _;
  }

  modifier whenCrowdsaleSuccessful() {
    require(isSuccessful());
    _;
  }

  modifier hasntStopped() {
    require(!stopped);
    _;
  }

  modifier hasBeenStopped() {
    require(stopped);
    _;
  }

  modifier hasntStarted() {
    require(!started);
    _;
  }

  modifier hasBeenStarted() {
    require(started);
    _;
  }

  // Minimal acceptable hard cap
  uint256 constant public MIN_HARD_CAP = 1 ether;

  // Minimal acceptable duration of crowdsale
  uint256 constant public MIN_CROWDSALE_TIME = 3 days;

  // Maximal acceptable duration of crowdsale
  uint256 constant public MAX_CROWDSALE_TIME = 50 days;

  // Becomes true when timeframe is assigned
  bool public started;

  // Becomes true if cancelled by owner
  bool public stopped;

  // Total collected Ethereum: must be updated every time tokens has been sold
  uint256 public totalCollected;

  // Total amount of project's token sold: must be updated every time tokens has been sold
  uint256 public totalSold;

  // Crowdsale minimal goal, must be greater or equal to Forecasting min amount
  uint256 public minimalGoal;

  // Crowdsale hard cap, must be less or equal to Forecasting max amount
  uint256 public hardCap;

  // Crowdsale duration in seconds.
  // Accepted range is MIN_CROWDSALE_TIME..MAX_CROWDSALE_TIME.
  uint256 public duration;

  // Start timestamp of crowdsale, absolute UTC time
  uint256 public startTimestamp;

  // End timestamp of crowdsale, absolute UTC time
  uint256 public endTimestamp;

  // Allows to transfer some ETH into the contract without selling tokens
  function deposit() public payable {}

  // Returns address of crowdsale token, must be ERC20 compilant
  function getToken() public returns(address);

  // Transfers ETH rewards amount (if ETH rewards is configured) to Forecasting contract
  function mintETHRewards(address _contract, uint256 _amount) public onlyManager();

  // Mints token Rewards to Forecasting contract
  function mintTokenRewards(address _contract, uint256 _amount) public onlyManager();

  // Releases tokens (transfers crowdsale token from mintable to transferrable state)
  function releaseTokens() public onlyManager() hasntStopped() whenCrowdsaleSuccessful();

  // Stops crowdsale. Called by CrowdsaleController, the latter is called by owner.
  // Crowdsale may be stopped any time before it finishes.
  function stop() public onlyManager() hasntStopped();

  // Validates parameters and starts crowdsale
  function start(uint256 _startTimestamp, uint256 _endTimestamp, address _fundingAddress)
    public onlyManager() hasntStarted() hasntStopped();

  // Is crowdsale failed (completed, but minimal goal wasn't reached)
  function isFailed() public constant returns (bool);

  // Is crowdsale active (i.e. the token can be sold)
  function isActive() public constant returns (bool);

  // Is crowdsale completed successfully
  function isSuccessful() public constant returns (bool);
}

contract BasicCrowdsale is ICrowdsaleProcessor {
  event CROWDSALE_START(uint256 startTimestamp, uint256 endTimestamp, address fundingAddress);
  //event DEBUG(uint256 value);

  // Where to transfer collected ETH
  address public fundingAddress;

  // Ctor.
  function BasicCrowdsale(
    address _owner,
    address _manager
  )
    public
  {
    owner = _owner;
    manager = _manager;
  }

  // called by CrowdsaleController to transfer reward part of ETH
  // collected by successful crowdsale to Forecasting contract.
  // This call is made upon closing successful crowdfunding process
  // iff agreed ETH reward part is not zero
  function mintETHRewards(
    address _contract,  // Forecasting contract
    uint256 _amount     // agreed part of totalCollected which is intended for rewards
  )
    public
    onlyManager() // manager is CrowdsaleController instance
  {
    require(_contract.call.value(_amount)());
  }

  // cancels crowdsale
  function stop() public onlyManager() hasntStopped()  {
    // we can stop only not started and not completed crowdsale
    if (started) {
      require(!isFailed());
      require(!isSuccessful());
    }
    stopped = true;
  }

  // called by CrowdsaleController to setup start and end time of crowdfunding process
  // as well as funding address (where to transfer ETH upon successful crowdsale)
  function start(
    uint256 _startTimestamp,
    uint256 _endTimestamp,
    address _fundingAddress
  )
    public
    onlyManager()   // manager is CrowdsaleController instance
    hasntStarted()  // not yet started
    hasntStopped()  // crowdsale wasn't cancelled
  {
    require(_fundingAddress != address(0));

    // start time must not be earlier than current time
    require(_startTimestamp >= block.timestamp);

    // range must be sane
    require(_endTimestamp > _startTimestamp);
    duration = _endTimestamp - _startTimestamp;

    // duration must fit constraints
    require(duration >= MIN_CROWDSALE_TIME && duration <= MAX_CROWDSALE_TIME);

    startTimestamp = _startTimestamp;
    endTimestamp = _endTimestamp;
    fundingAddress = _fundingAddress;

    // now crowdsale is considered started, even if the current time is before startTimestamp
    started = true;

    emit CROWDSALE_START(_startTimestamp, _endTimestamp, _fundingAddress);
  }

  // must return true if crowdsale is over, but it failed
  function isFailed()
    public
    constant
    returns(bool)
  {
    return (
      // it was started
      started &&

      // crowdsale period has finished
      block.timestamp >= endTimestamp &&

      // but collected ETH is below the required minimum
      totalCollected < minimalGoal
    );
  }

  // must return true if crowdsale is active (i.e. the token can be bought)
  function isActive()
    public
    constant
    returns(bool)
  {
    return (
      // it was started
      started &&

      // hard cap wasn't reached yet
      totalCollected < hardCap &&

      // and current time is within the crowdfunding period
      block.timestamp >= startTimestamp &&
      block.timestamp < endTimestamp
    );
  }

  // must return true if crowdsale completed successfully
  function isSuccessful()
    public
    constant
    returns(bool)
  {
    return (
      // either the hard cap is collected
      totalCollected >= hardCap ||

      // ...or the crowdfunding period is over, but the minimum has been reached
      (block.timestamp >= endTimestamp && totalCollected >= minimalGoal)
    );
  }
}

contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;
  function AddToWhiteList(address _addr) public onlyOwner {
      whitelist[_addr] = true;
  }

  modifier whitelistedOnly {
    require(whitelist[msg.sender]);
    _;
  }
}

contract Crowdsale is BasicCrowdsale, Whitelist, WithBonusPeriods {

  struct Investor {
    uint256 weiDonated;
    uint256 tokensGiven;
  }

  mapping(address => Investor) participants;

  uint256 public tokenRateWei;
  LetItPlayToken public token;

  // Ctor. In this example, minimalGoal, hardCap, and price are not changeable.
  // In more complex cases, those parameters may be changed until start() is called.
  function Crowdsale(
    uint256 _minimalGoal,
    uint256 _hardCap,
    uint256 _tokenRateWei,
    address _token
  )
    public
    // simplest case where manager==owner. See onlyOwner() and onlyManager() modifiers
    // before functions to figure out the cases in which those addresses should differ
    BasicCrowdsale(msg.sender, msg.sender)
  {
    // just setup them once...
    minimalGoal = _minimalGoal;
    hardCap = _hardCap;
    tokenRateWei = _tokenRateWei;
    token = LetItPlayToken(_token);
  }

  /*function initPresaleItem(address addr, uint256 eth, uint256 tokens) internal{
        participants[addr].weiDonated += eth;
        participants[addr].tokensGiven += tokens;
        token.transferByCrowdsale(addr, tokens);
  }

  function initPresale() public onlyOwner() {
        initPresaleItem(0xa4dba833494db5a101b82736bce558c05d78479,  1, 10);
        initPresaleItem(0xb0b5594fb4ff44ac05b2ff65aded3c78a8a6b5a5, 3, 30);
  }*/

// Here goes ICrowdsaleProcessor implementation

  // returns address of crowdsale token. The token must be ERC20-compliant
  function getToken()
    public
    returns(address)
  {
    return address(token);
  }

  // called by CrowdsaleController to transfer reward part of
  // tokens sold by successful crowdsale to Forecasting contract.
  // This call is made upon closing successful crowdfunding process.
  function mintTokenRewards(
    address _contract,  // Forecasting contract
    uint256 _amount     // agreed part of totalSold which is intended for rewards
  )
    public
    onlyManager() // manager is CrowdsaleController instance
  {
    // crowdsale token is mintable in this example, tokens are created here
    token.transferByCrowdsale(_contract, _amount);
  }

  // transfers crowdsale token from mintable to transferrable state
  function releaseTokens()
    public
    onlyManager()             // manager is CrowdsaleController instance
    hasntStopped()            // crowdsale wasn't cancelled
    whenCrowdsaleSuccessful() // crowdsale was successful
  {
    // see token example
    token.releaseForTransfer();
  }

  function () payable public {
    require(msg.value > 0);
    sellTokens(msg.sender, msg.value);
  }

  function sellTokens(address _recepient, uint256 _value)
    internal
    hasBeenStarted()
    hasntStopped()
    whenCrowdsaleAlive()
    whitelistedOnly()
  {
    uint256 newTotalCollected = totalCollected + _value;

    if (hardCap < newTotalCollected) {
      uint256 refund = newTotalCollected - hardCap;
      uint256 diff = _value - refund;
      _recepient.transfer(refund);
      _value = diff;
    }

    uint256 tokensSold = _value * uint256(10)**token.decimals() / tokenRateWei;
    updateCurrentBonusPeriod();
    if (currentBonusPeriod.fromTimestamp != INVALID_FROM_TIMESTAMP)
      tokensSold += tokensSold * currentBonusPeriod.bonusNumerator / currentBonusPeriod.bonusDenominator;

    token.transferByCrowdsale(_recepient, tokensSold);
    participants[_recepient].weiDonated += _value;
    participants[_recepient].tokensGiven += tokensSold;
    totalCollected += _value;
    totalSold += tokensSold;
  }

  // project's owner withdraws ETH funds to the funding address upon successful crowdsale
  function withdraw(uint256 _amount) public // can be done partially
    onlyOwner() // project's owner
    hasntStopped()  // crowdsale wasn't cancelled
    whenCrowdsaleSuccessful() // crowdsale completed successfully
  {
    require(_amount <= address(this).balance);
    fundingAddress.transfer(_amount);
  }

  // backers refund their ETH if the crowdsale was cancelled or has failed
  function refund() public
  {
    // either cancelled or failed
    require(stopped || isFailed());

    uint256 weiDonated = participants[msg.sender].weiDonated;
    uint256 tokens = participants[msg.sender].tokensGiven;

    // prevent from doing it twice
    require(weiDonated > 0);
    //DEBUG(weiDonated);
    participants[msg.sender].weiDonated = 0;
    participants[msg.sender].tokensGiven = 0;

    msg.sender.transfer(weiDonated);

    //this must be approved by investor
    token.transferFromByCrowdsale(msg.sender, token.forSale(), tokens);
  }
}

contract LetItPlayToken is Crowdsaled, StandardToken {
        uint256 public totalSupply;
        string public name;
        string public symbol;
        uint8 public decimals;

        address public forSale;
        address public preSale;
        address public ecoSystemFund;
        address public founders;
        address public team;
        address public advisers;
        address public bounty;

        bool releasedForTransfer;

        uint256 private shift;

        function LetItPlayToken(
            address _forSale,
            address _ecoSystemFund,
            address _founders,
            address _team,
            address _advisers,
            address _bounty,
            address _preSale,
            uint256 _preSaleTokens
          ) public {
          name = "LetItPlayToken";
          symbol = "PLAY";
          decimals = 8;
          shift = uint256(10)**decimals;
          totalSupply = 1000000000 * shift;
          forSale = _forSale;
          ecoSystemFund = _ecoSystemFund;
          founders = _founders;
          team = _team;
          advisers = _advisers;
          bounty = _bounty;
          preSale = _preSale;

          uint256 forSaleTokens = totalSupply * 60 / 100;
          _preSaleTokens = _preSaleTokens * shift;

          balances[forSale] = forSaleTokens - _preSaleTokens;
          balances[preSale] = _preSaleTokens;
          balances[ecoSystemFund] = totalSupply * 15 / 100;
          balances[founders] = totalSupply * 15 / 100;
          balances[team] = totalSupply * 5 / 100;
          balances[advisers] = totalSupply * 3 / 100;
          balances[bounty] = totalSupply * 2 / 100;
        }

        function transferByOwner(address from, address to, uint256 value) public onlyOwner {
          require(balances[from] >= value);
          balances[from] = balances[from].sub(value);
          balances[to] = balances[to].add(value);
          emit Transfer(from, to, value);
        }

        function transferByCrowdsale(address to, uint256 value) public onlyCrowdsale {
          require(balances[forSale] >= value);
          balances[forSale] = balances[forSale].sub(value);
          balances[to] = balances[to].add(value);
          emit Transfer(forSale, to, value);
        }

        function transferFromByCrowdsale(address _from, address _to, uint256 _value) public onlyCrowdsale returns (bool) {
            return super.transferFrom(_from, _to, _value);
        }

        function releaseForTransfer() public onlyCrowdsaleOrOwner {
          require(!releasedForTransfer);
          releasedForTransfer = true;
        }

        function transfer(address _to, uint256 _value) public returns (bool) {
          require(releasedForTransfer);
          return super.transfer(_to, _value);
        }

        function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
           require(releasedForTransfer);
           return super.transferFrom(_from, _to, _value);
        }
}
