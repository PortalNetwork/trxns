pragma solidity >=0.4.23 <0.6.0;

import "./TNS.sol";
import "./IERC721.sol";
import "./Ownable.sol";

contract BaseRegistrar is IERC721, Ownable {
    uint constant public GRACE_PERIOD = 90 days;

    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);
    event NameMigrated(uint256 indexed id, address indexed owner, uint expires);
    event NameRegistered(uint256 indexed id, address indexed owner, uint expires);
    event NameRenewed(uint256 indexed id, uint expires);

    // Expiration timestamp for migrated domains.
    uint public transferPeriodEnds;

    // The TNS registry
    TNS public tns;

    // The namehash of the TLD this registrar owns (eg, .eth)
    bytes32 public baseNode;

    // A map of addresses that are authorised to register and renew names.
    mapping(address=>bool) public controllers;

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external;

    // Revoke controller permission for an address.
    function removeController(address controller) external;

    // Set the resolver for the TLD this registrar manages.
    function setResolver(address resolver) external;

    // Returns the expiration timestamp of the specified label hash.
    function nameExpires(uint256 id) external view returns(uint);

    // Returns true iff the specified name is available for registration.
    function available(uint256 id) public view returns(bool);

    /**
     * @dev Register a name.
     */
    function register(uint256 id, address owner, uint duration) external returns(uint);

    function renew(uint256 id, uint duration) external returns(uint);

    /**
     * @dev Transfers a registration from the initial registrar.
     * This function is called by the initial registrar when a user calls `transferRegistrars`.
     */
    function acceptRegistrarTransfer(bytes32 label, uint) external;
}