pragma solidity >=0.4.23 <0.6.0;

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
  //PriceOracle prices;

  constructor(BaseRegistrar _base) public {
    base = _base;
  }

  function valid(string memory name) public view returns(bool) {
    return name.strlen() > 6;
  }

  function available(string memory name) public view returns(bool) {
    bytes32 label = keccak256(bytes(name));
    return valid(name) && base.available(uint256(label));
  }

  function register(string calldata name, address owner, uint duration, bytes32 secret) external payable {

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
