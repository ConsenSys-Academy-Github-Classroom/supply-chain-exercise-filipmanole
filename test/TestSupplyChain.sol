pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";
import "./MockHelper.sol";

contract TestSupplyChain {

  uint public initialBalance = 30 ether;
  SupplyChain supplyChain;
  MockHelper seller;
  MockHelper buyer;

  function beforeAll() public {
    supplyChain = new SupplyChain();

    seller = new MockHelper(supplyChain);
    buyer = new MockHelper(supplyChain);

    /* Send ether to the contracts to perform transactions */
    (bool success, ) = address(seller).call.value(10 ether)("");
    (success, ) = address(buyer).call.value(10 ether)("");
  }

  /* Add item test */

  function testForAddedItem() public {
    bool success = seller.mockAddItem("Candy", 3 ether);
    Assert.isTrue(success, "should add an item to the supply chain");

    (string memory _name, uint _sku, uint _price, uint _state, address _seller, address _buyer) = supplyChain.fetchItem(0);

    Assert.equal(_name, "Candy", "The name of the item should be 'Candy'");
    Assert.equal(_sku, 0, "The index of the item should be 0");
    Assert.equal(_price, 3 ether, "The price of the item should be 3 ether");
    Assert.equal(_state, 0, "The state of the item should be 0 (ForSale)");
    Assert.equal(_seller, address(seller), "The address of the item should be the address of the seller");
    Assert.equal(_buyer, address(0), "The index of the item should be the NULL adress");
  }

  /* Buying item tests */

  /* Test for failure if user does not send enough funds */
  function testForFailureIfUserDoesNotSendEnoughFunds() public {
    bool success = buyer.mockBuyItem(0, 2 ether);
    Assert.isFalse(success, "should not buy an item when paying fewer ethers");
  }
  /* Test for purchasing an item that is not for Sale */
  function testForPurchasingAnItemThatIsNotForSale() public payable {
    bool success = buyer.mockBuyItem(0, 3 ether);
    Assert.isTrue(success, "should buy the item; enough ether sent");

    (, , , uint _state, ,) = supplyChain.fetchItem(0);
    Assert.notEqual(_state, 0, "should not be in for Sale state");

    success = buyer.mockBuyItem(0, 3 ether);
    Assert.isFalse(success, "should not buy an item not marked as for Sale");
  }

  /* Shipping item tests */

  /* Test for calls that are made by not the seller */
  function testForCallsThatAreMadeByNotTheSeller() public {
    bool success = buyer.mockShipItem(0);
    Assert.isFalse(success, "should not ship the item; the action is not performed by the seller");
  }
  /* Test for trying to ship an item that is not marked Sold */
  function testForTryingToShipAnItemThatIsNotMarkedAsSold() public {
    bool success = seller.mockShipItem(0);
    Assert.isTrue(success, "should ship the item");

    (, , , uint _state, ,) = supplyChain.fetchItem(0);
    Assert.notEqual(_state, 1, "should not be in Sold state");

    success = seller.mockShipItem(0);
    Assert.isFalse(success, "should not ship the item not marked as Sold");
  }

  /* Receiveing item tests */

  /* Test calling the function from an address that is not the buyer */
  function testCallingTheReceiveItemFunctionFromAnAddressThatIsNotTheBuyer() public {
    bool success = seller.mockReceiveItem(0);
    Assert.isFalse(success, "should not receive an item; the action is not performed by the buyer");
  }
  /* Test calling the function on an item not marked Shipped */
  function testCallingTheReceiveItemFunctionOnAnItemNotMarkedShipped() public {
    bool success = buyer.mockReceiveItem(0);
    Assert.isTrue(success, "should receive the item");

    (, , , uint _state, ,) = supplyChain.fetchItem(0);
    Assert.notEqual(_state, 2, "should not be in Shipped state");

    success = buyer.mockReceiveItem(0);
    Assert.isFalse(success, "should not receive an item that is not marked as Shipped ");
  }

  function () external payable {}
}
