pragma solidity >=0.4.23 <0.6.0;

import "./TNS.sol";
import "./ERC721.sol";
import "./Ownable.sol";
import "./BaseRegistrar.sol";

contract BaseRegistrarImplementation is BaseRegistrar, ERC721 {
    // A map of expiry times
    mapping(uint256=>uint) expiries;

    uint constant public MIGRATION_LOCK_PERIOD = 28 days;

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant private ERC721_ID = bytes4(
        keccak256("balanceOf(uint256)") ^
        keccak256("ownerOf(uint256)") ^
        keccak256("approve(address,uint256)") ^
        keccak256("getApproved(uint256)") ^
        keccak256("setApprovalForAll(address,bool)") ^
        keccak256("isApprovedForAll(address,address)") ^
        keccak256("transferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256)") ^
        keccak256("safeTransferFrom(address,address,uint256,bytes)")
    );
    bytes4 constant private RECLAIM_ID = bytes4(keccak256("reclaim(uint256,address)"));

    constructor(TNS _tns, bytes32 _baseNode) public {
        tns = _tns;
        baseNode = _baseNode;
    }

    modifier live {
        require(tns.owner(baseNode) == address(this));
        _;
    }

    modifier onlyController {
        require(controllers[msg.sender]);
        _;
    }

    /**
     * @dev Gets the owner of the specified token ID. Names become unowned
     *      when their registration expires.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        require(expiries[tokenId] > now);
        return super.ownerOf(tokenId);
    }

    // Authorises a controller, who can register and renew domains.
    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
        emit ControllerAdded(controller);
    }

    // Revoke controller permission for an address.
    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
        emit ControllerRemoved(controller);
    }

    // Set the resolver for the TLD this registrar manages.
    function setResolver(address resolver) external onlyOwner {
        tns.setResolver(baseNode, resolver);
    }

    // Returns the expiration timestamp of the specified id.
    function nameExpires(uint256 id) external view returns(uint) {
        return expiries[id];
    }

    // Returns true iff the specified name is available for registration.
    function available(uint256 id) public view returns(bool) {
        // Not available if it's registered here or in its grace period.
        if(expiries[id] + GRACE_PERIOD >= now) {
            return false;
        }
        // Available if we're past the transfer period, or the name isn't
        // registered in the legacy registrar.
        return true;
    }

    /**
     * @dev Register a name.
     */
    function register(uint256 id, address owner, uint duration) external live onlyController returns(uint) {
        require(available(id));
        require(now + duration + GRACE_PERIOD > now + GRACE_PERIOD); // Prevent future overflow

        expiries[id] = now + duration;
        if(_exists(id)) {
            // Name was previously owned, and expired
            _burn(id);
        }
        _mint(owner, id);
        tns.setSubnodeOwner(baseNode, bytes32(id), owner);

        emit NameRegistered(id, owner, now + duration);

        return now + duration;
    }

    function renew(uint256 id, uint duration) external live onlyController returns(uint) {
        require(expiries[id] + GRACE_PERIOD >= now); // Name must be registered here or in grace period
        require(expiries[id] + duration + GRACE_PERIOD > duration + GRACE_PERIOD); // Prevent future overflow

        expiries[id] += duration;
        emit NameRenewed(id, expiries[id]);
        return expiries[id];
    }

    /**
     * @dev Transfers a registration from the initial registrar.
     * This function is called by the initial registrar when a user calls `transferRegistrars`.
     */
    function acceptRegistrarTransfer(bytes32 label, uint) external live {
        /*uint256 id = uint256(label);

        require(msg.sender == address(previousRegistrar));
        require(expiries[id] == 0);
        require(transferPeriodEnds > now);

        uint registrationDate;
        (,,registrationDate,,) = previousRegistrar.entries(label);
        require(registrationDate < now - MIGRATION_LOCK_PERIOD);

        address owner = deed.owner();

        // Destroy the deed and transfer the funds back to the registrant.
        deed.closeDeed(1000);

        // Register the name
        expiries[id] = transferPeriodEnds;
        _mint(owner, id);

        tns.setSubnodeOwner(baseNode, label, owner);

        emit NameMigrated(id, owner, transferPeriodEnds);
        emit NameRegistered(id, owner, transferPeriodEnds);*/
    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool) {
        return interfaceID == INTERFACE_META_ID ||
               interfaceID == ERC721_ID ||
               interfaceID == RECLAIM_ID;
    }
}