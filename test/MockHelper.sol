pragma solidity ^0.5.0;

import "../contracts/SupplyChain.sol";

contract MockHelper {

  SupplyChain supplyChain;

  constructor(SupplyChain _supplyChain) public {
    supplyChain = _supplyChain;
  }

  function mockAddItem(string memory itemName, uint256 itemValue) public returns (bool) {
    return supplyChain.addItem(itemName, itemValue);
  }

  function mockBuyItem(uint sku, uint value) public returns (bool) {
    (bool success, ) = address(supplyChain).call.value(value)(abi.encodeWithSignature("buyItem(uint256)", sku));
    return success;
  }

  function mockShipItem(uint sku) public returns (bool) {
    (bool success, ) = address(supplyChain).call(abi.encodeWithSignature("shipItem(uint256)", sku));
    return success;
  }

  function mockReceiveItem(uint sku) public returns (bool) {
    (bool success, ) = address(supplyChain).call(abi.encodeWithSignature("receiveItem(uint256)", sku));
    return success;
  }

  function () external payable {}
}
