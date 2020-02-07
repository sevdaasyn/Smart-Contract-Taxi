### What does this project do?
This project is aimed to create a smart contract that handles a common asset and distribution of income
generated from this asset in certain time intervals. The common asset in this scenario is a taxi.

### How to deploy?
When deploying this project value should be set a value which will be contract balance later. 
The account you deploy will be manager's address.

### How a participant can join?
Any account can join by setting value to participation fee with Join() function.

### How to set car dealer?
Copy an account address and set give it to SetCarDealer() function as parameter.
This account will be dealer.

### How car purchase a car?
Dealer should first specify car id, price and offer valid time by CarProposeToBusiness() function.
After that at least half of the participants must approve this propose by ApprovePurchaseCar() function.
If at least half of the participants are approved, manager purchases car with PurchaseCar() function.

### How to repurchase car?
First dealer sets propose info in RepurchaseCarPropose() function.
After that at least half of the participants must approve this propose by ApproveSellProposal() function.
If at least half of the participants are approved, dealer purchases car with RepurchaseCar() function.

### How to set driver?
Fist manager proposes a driver with ProposeDriver function.
After that at least half of the participants must approve this propose by ApproveDriver() function.
If at least half of the participants are approved, manager sets driver with SetDriver() function.
Manager can fire driver with FireDriver() function if s/he want.

### How costomers pay for taxi?
Any account except assigned participant, manager, driver and driver can be customer.
By using GetCharge() customers can pay to contract for taxi.
Amount to be payed should be specified by value.

