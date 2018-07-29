pragma solidity ^0.4.24;

import "./PetCoin.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";


/**
 * @title PetCoinCrowdSale
 * @dev PetCoinCrowdSale is the contract for managing petcoin crowdsale,
 * allowing investors to purchase petcoin tokens with ether.
 */
contract PetCoinCrowdSale is Owned {
  using SafeMath for uint256;
  using SafeERC20 for PetCoin;

  // Conversion rates
  uint256 public stageOneRate = 4500; // 1 ETH = 4500 PETC
  uint256 public stageTwoRate = 3000; // 1 ETH = 3000 PETC
  uint256 public stageThreeRate = 2557; // 1 ETH = 2557 PETC

  // The token being sold
  PetCoin public token;

  // Address where funds are collected
  address public wallet;

  // Amount of wei raised
  uint256 public weiRaised;


  // Token Sale State Definitions
  enum TokenSaleState { NOT_STARTED, STAGE_ONE, STAGE_TWO, STAGE_THREE, COMPLETED }

  TokenSaleState public state;

  struct Stage {
    uint256 rate;
    uint256 remaining;
  }

  // Enum as mapping key not supported by Solidity yet
  mapping(uint256 => Stage) public stages;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    uint256 value,
    uint256 amount
  );


  /**
   * Event for refund in case remaining tokens are not sufficient
   * @param purchaser who paid for the tokens
   * @param value weis refunded
   */
  event Refund(
    address indexed purchaser,
    uint256 value
  );

  /**
   * Event for move stage
   * @param oldState old state
   * @param newState new state
   */
  event MoveStage(
    TokenSaleState oldState,
    TokenSaleState newState
  );

  /**
 * Event for rates update
 * @param who updated the rates
 * @param stageOneRate new stageOneRate
 * @param stageTwoRate new stageTwoRate
 * @param stageThreeRate new stageThreeRate
 */
  event RatesUpdate(
    address indexed who,
    uint256 stageOneRate,
    uint256 stageTwoRate,
    uint256 stageThreeRate
  );

  /**
   * @param _token Address of the token being sold
   * @param _wallet Address where collected funds will be forwarded to
   */
  constructor(PetCoin _token, address _wallet)
    public
  {
    require(_token != address(0));
    require(_wallet != address(0));

    token = _token;
    wallet = _wallet;

    state = TokenSaleState.NOT_STARTED;
    stages[uint256(TokenSaleState.STAGE_ONE)] = Stage(stageOneRate, token.stageOneSupply());
    stages[uint256(TokenSaleState.STAGE_TWO)] = Stage(stageTwoRate, token.stageTwoSupply());
    stages[uint256(TokenSaleState.STAGE_THREE)] = Stage(stageThreeRate, token.stageThreeSupply());
  }


  // Modifiers
  modifier notStarted() {
    require (state == TokenSaleState.NOT_STARTED);
    _;
  }

  modifier stageOne() {
    require (state == TokenSaleState.STAGE_ONE);
    _;
  }

  modifier stageTwo() {
    require (state == TokenSaleState.STAGE_TWO);
    _;
  }

  modifier stageThree() {
    require (state == TokenSaleState.STAGE_THREE);
    _;
  }

  modifier completed() {
    require (state == TokenSaleState.COMPLETED);
    _;
  }

  modifier saleInProgress() {
    require (state == TokenSaleState.STAGE_ONE || state == TokenSaleState.STAGE_TWO || state == TokenSaleState.STAGE_THREE);
    _;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  function kickoff()
    external
    onlyOwner
    notStarted
  {
    _moveStage();
  }


  function updateRates(uint256 _stageOneRate, uint256 _stageTwoRate, uint256 _stageThreeRate)
    external
    onlyOwner
  {
    stageOneRate = _stageOneRate;
    stageTwoRate = _stageTwoRate;
    stageThreeRate = _stageThreeRate;
    stages[uint256(TokenSaleState.STAGE_ONE)].rate = stageOneRate;
    stages[uint256(TokenSaleState.STAGE_TWO)].rate = stageTwoRate;
    stages[uint256(TokenSaleState.STAGE_THREE)].rate = stageThreeRate;
    emit RatesUpdate(msg.sender, stageOneRate, stageTwoRate, stageThreeRate);
  }

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function ()
    external
    payable
    saleInProgress
  {
    require(stages[uint256(state)].rate > 0);
    require(stages[uint256(state)].remaining > 0);
    require(msg.value > 0);

    uint256 weiAmount = msg.value;
    uint256 refund = 0;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(stages[uint256(state)].rate);

    if (tokens > stages[uint256(state)].remaining) {
      // calculate wei needed to purchase the remaining tokens
      tokens = stages[uint256(state)].remaining;
      weiAmount = tokens.div(stages[uint256(state)].rate);
      refund = msg.value - weiAmount;
    }

    // update state
    weiRaised = weiRaised.add(weiAmount);

    // transfer tokens to buyer
    token.safeTransfer(msg.sender, tokens);

    emit TokenPurchase(
      msg.sender,
      weiAmount,
      tokens
    );

    // update remaining of the stage
    stages[uint256(state)].remaining -= tokens;
    assert(stages[uint256(state)].remaining >= 0);

    if (stages[uint256(state)].remaining == 0) {
      _moveStage();
    }

    if (refund > 0) { // refund the purchaser if required
      msg.sender.transfer(refund);
      emit Refund(
        msg.sender,
        refund
      );
    }

    _forwardFunds();
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  function _moveStage()
    internal
  {
    TokenSaleState oldState = state;
    if (state == TokenSaleState.NOT_STARTED) {
      state = TokenSaleState.STAGE_ONE;
    } else if (state == TokenSaleState.STAGE_ONE) {
      state = TokenSaleState.STAGE_TWO;
    } else if (state == TokenSaleState.STAGE_TWO) {
      state = TokenSaleState.STAGE_THREE;
    } else if (state == TokenSaleState.STAGE_THREE) {
      state = TokenSaleState.COMPLETED;
    }
    emit MoveStage(oldState, state);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
