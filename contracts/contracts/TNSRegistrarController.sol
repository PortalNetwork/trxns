pragma solidity >=0.4.23 <0.6.0;

import "./PriceOracle.sol";
import "./BaseRegistrar.sol";
import "./StringUtils.sol";
import "./Ownable.sol";

/**
 * @dev A registrar controller for registering and renewing names.
 */
contract TNSRegistrarController is Ownable {
  using StringUtils for *;

  bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

  //mapping(bytes32=>uint) public commitments;

  event NameRegistered(string name, bytes32 indexed label, address indexed owner, uint cost, uint expires);
  event NameRenewed(string name, bytes32 indexed label, uint cost, uint expires);

  BaseRegistrar base;
  PriceOracle prices;

  uint constant public MIN_REGISTRATION_DURATION = 28 days;

  constructor(BaseRegistrar _base, PriceOracle _prices) public {
    base = _base;
    prices = _prices;
  }

  function valid(string memory name) public view returns(bool) {
    return name.strlen() > 6;
  }

  function available(string memory name) public view returns(bool) {
    bytes32 label = keccak256(bytes(name));
    return valid(name) && base.available(uint256(label));
  }

  function register(string calldata name, address owner, uint duration, bytes32 secret) external payable {
    uint cost = 0.1 ether; //rentPrice(name, duration);
    require(duration >= MIN_REGISTRATION_DURATION);
    require(msg.value >= cost);
    
    bytes32 label = keccak256(bytes(name));
    uint expires = base.register(uint256(label), owner, duration);

    emit NameRegistered(name, label, owner, cost, expires);

    if(msg.value > cost) {
      msg.sender.transfer(msg.value - cost);
    }
  }

  function renew(string calldata name, uint duration) external payable {

  }

  function withdraw() public onlyOwner {
    msg.sender.transfer(address(this).balance);
  }

  function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    return interfaceID == INTERFACE_META_ID;
  }

}
