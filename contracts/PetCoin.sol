pragma solidity ^0.4.24;

import "./StandardToken.sol";
import "./Owned.sol";

/**
 * @title The PetCoin Token contract.
 */
contract PetCoin is StandardToken, Owned {

  // Token metadata
  string public constant name = "Petcoin";
  string public constant symbol = "PETC";
  uint256 public constant decimals = 18;

  // Token supply breakdown
  uint256 public constant initialSupply = 2340 * (10**6) * 10**decimals; // 2.34 billion
  uint256 public constant stageOneSupply = (10**5) * 10**decimals; // 100,000 tokens for ICO stage 1
  uint256 public constant stageTwoSupply = (10**6) * 10*decimals; // 1,000,000 tokens for ICO stage 2
  uint256 public constant stageThreeSupply = (10**7) * 10*decimals; // 10,000,000 tokens for ICO stage 3

  // Initial Token holder addresses. !!!Important!!! TODO rename the addresses meaningfully and set the right values
  // one billion token holders
  address public constant a1 = 0xf088394D9AEec53096A18Fb192C98FD90495416C;
  address public constant a2 = 0x18429e9a0282D8a1483154A30C612293877b6273;
  // one hundred million token holders
  address public constant a3 = 0xFa8c26d4d8a24fB880b7DBf91C19AdbC218c6322;
  address public constant a4 = 0xE93381fB4c4F14bDa253907b18faD305D799241a;
  address public constant a5 = 0x7e9c55e5Ad1A2dbC4a98606B2C7855d7785E22b0;
  // the rest token holder
  address public constant a6 = 0x41A313bC923927A86a384c9128718300Fd75C34F;

  // mint configuration
  uint256 public constant yearlyMintCap = (10*7) * 10*decimals; //10,000,000 tokens each year
  uint16 public mintStartYear = 2019;
  uint16 public mintEndYear = 2118;

  mapping (uint16 => bool) minted;


  constructor()
    public
  {
    totalSupply_ = initialSupply.add(stageOneSupply).add(stageTwoSupply).add(stageThreeSupply);
    balances[a1] = (10**9) * 10**decimals; // 1 billion tokens
    balances[a2] = (10**9) * 10**decimals; // 1 billion tokens
    balances[a3] = 100 * (10**6) * 10**decimals; // 100 million tokens
    balances[a4] = 100 * (10**6) * 10**decimals; // 100 million tokens
    balances[a5] = 100 * (10**6) * 10**decimals; // 100 million tokens
    balances[a6] = initialSupply.sub(balances[1]).sub(balances[2]).sub(balances[3]).sub(balances[4]).sub(balances[5]); // the rest
    balances[msg.sender] = stageOneSupply.add(stageTwoSupply).add(stageThreeSupply);
  }

  event Mint(address indexed to, uint256 amount);

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to
  )
    onlyOwner
    public
    returns (bool)
  {
    uint16 year = _getYear(now);
    require (year >= mintStartYear && year <= mintEndYear && !minted[year]);
    require (_to != address(0));

    totalSupply_ = totalSupply_.add(yearlyMintCap);
    balances[_to] = balances[_to].add(yearlyMintCap);
    minted[year] = true;

    emit Mint(_to, yearlyMintCap);
    emit Transfer(address(0), _to, yearlyMintCap);
    return true;
  }

  function _getYear(uint256 timestamp)
    internal
    pure
    returns (uint16)
  {
    uint16 ORIGIN_YEAR = 1970;
    uint256 YEAR_IN_SECONDS = 31536000;
    uint256 LEAP_YEAR_IN_SECONDS = 31622400;

    uint secondsAccountedFor = 0;
    uint16 year;
    uint numLeapYears;

    // Year
    year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
    numLeapYears = _leapYearsBefore(year) - _leapYearsBefore(ORIGIN_YEAR);

    secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
    secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

    while (secondsAccountedFor > timestamp) {
      if (_isLeapYear(uint16(year - 1))) {
        secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
      }
      else {
        secondsAccountedFor -= YEAR_IN_SECONDS;
      }
      year -= 1;
    }
    return year;
  }

  function _isLeapYear(uint16 year)
    internal
    pure
    returns (bool)
  {
    if (year % 4 != 0) {
      return false;
    }
    if (year % 100 != 0) {
      return true;
    }
    if (year % 400 != 0) {
      return false;
    }
    return true;
  }

  function _leapYearsBefore(uint year)
    internal
    pure
    returns (uint)
  {
    year -= 1;
    return year / 4 - year / 100 + year / 400;
  }

}