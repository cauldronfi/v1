pragma solidity 0.6.12;

import "@openzeppelin/contracts/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract CauldronFi is ERC20PresetMinterPauser, Ownable{
    using SafeMath for uint256;
    uint256 public buyCap = 120 ether;
    uint256 public ratePerWei = 1000;
    uint256 public bought = 0;

    
    function setBuyCap(uint256 n) external onlyOwner {
        buyCap = n;
    }
    function setRatePerWei(uint256 n) external onlyOwner {
        ratePerWei = n;
    }

    constructor() public ERC20PresetMinterPauser("CauldronFi","CLDRN"){
    }
    function buy() public payable{
        require(msg.value > 0, "min");

        uint256 buyAmt = msg.value;
        uint256 refundAmt = 0;
        uint256 temp = buyAmt.add(bought);
        if (temp > buyCap){
            uint256 delta = temp.sub(buyCap);
            buyAmt = buyAmt.sub(delta);
            refundAmt = delta;
        }
        uint256 toSend = buyAmt.mul(ratePerWei);
        bought = bought.add(buyAmt);
        _mint(msg.sender, toSend);

        if (refundAmt > 0){
            msg.sender.transfer(refundAmt);
        }
    }
    function withdraw() external onlyOwner {
        address payable p = payable(owner());
        p.transfer(address(this).balance);
    }
    receive() external payable {
        buy();
    }
   function addMinter(address a) external onlyOwner {
        grantRole(MINTER_ROLE, a);
    }
    function addPauser(address a) external onlyOwner {
        grantRole(PAUSER_ROLE, a);
    }
    function revokeMinter(address a) external onlyOwner {
        revokeRole(MINTER_ROLE, a);
    }
    function revokePauser(address a) external onlyOwner {
        revokeRole(PAUSER_ROLE, a);
    }
}
