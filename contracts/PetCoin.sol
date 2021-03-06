pragma solidity ^0.4.24;

import "./StandardToken.sol";
import "./Owned.sol";
import "./SafeMath.sol";

/**
 * @title The PetCoin Token contract.
 */
contract PetCoin is StandardToken, Owned {

  using SafeMath for uint256;

  // Token metadata
  string public constant name = "Petcoin";
  string public constant symbol = "PETC";
  uint256 public constant decimals = 18;

  // Token supply breakdown
  uint256 public constant initialSupply = 2340 * (10**6) * 10**decimals; // 2.34 billion
  uint256 public constant stageOneSupply = (10**5) * 10**decimals; // 100,000 tokens for ICO stage 1
  uint256 public constant stageTwoSupply = (10**6) * 10**decimals; // 1,000,000 tokens for ICO stage 2
  uint256 public constant stageThreeSupply = (10**7) * 10**decimals; // 10,000,000 tokens for ICO stage 3

  // Initial Token holder addresses.
  // one billion token holders
  address public constant appWallet = 0x9F6899364610B96D7718Fe3c03A6BD1Deb8623CE;
  address public constant genWallet = 0x530E6B9A17e9AbB77CF4E125b99Bf5D5CAD69942;
  // one hundred million token holders
  address public constant ceoWallet = 0x388Ed3f7Aa1C4461460197FcCE5cfEf84D562c6A;
  address public constant cooWallet = 0xa2c59e6a91B4E502CF8C95A61F50D3aB1AB30cBA;
  address public constant devWallet = 0x7D2ea29E2d4A95f4725f52B941c518C15eAE3c64;
  // the rest token holder
  address public constant poolWallet = 0x7e75fe6b73993D9Be9cb975364ec70Ee2C22c13A;

  // mint configuration
  uint256 public constant yearlyMintCap = (10*7) * 10*decimals; //10,000,000 tokens each year
  uint16 public mintStartYear = 2019;
  uint16 public mintEndYear = 2118;

  mapping (uint16 => bool) minted;


  constructor()
    public
  {
    totalSupply_ = initialSupply.add(stageOneSupply).add(stageTwoSupply).add(stageThreeSupply);
    uint256 oneBillion = (10**9) * 10**decimals;
    uint256 oneHundredMillion = 100 * (10**6) * 10**decimals;
    balances[appWallet] = oneBillion;
    emit Transfer(address(0), appWallet, oneBillion);
    balances[genWallet] = oneBillion;
    emit Transfer(address(0), genWallet, oneBillion);
    balances[ceoWallet] = oneHundredMillion;
    emit Transfer(address(0), ceoWallet, oneHundredMillion);
    balances[cooWallet] = oneHundredMillion;
    emit Transfer(address(0), cooWallet, oneHundredMillion);
    balances[devWallet] = oneHundredMillion;
    emit Transfer(address(0), devWallet, oneHundredMillion);
    balances[poolWallet] = initialSupply.sub(balances[appWallet])
    .sub(balances[genWallet])
    .sub(balances[ceoWallet])
    .sub(balances[cooWallet])
    .sub(balances[devWallet]);
    emit Transfer(address(0), poolWallet, balances[poolWallet]);
    balances[msg.sender] = stageOneSupply.add(stageTwoSupply).add(stageThreeSupply);
    emit Transfer(address(0), msg.sender, balances[msg.sender]);
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
    external
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