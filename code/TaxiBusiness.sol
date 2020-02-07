pragma solidity >=0.4.22 <0.6.0;

contract My_Taxi{
    
    mapping (address => uint) balances_participant;
    mapping (address => uint) account_participant;
    address[] addresses_participant;    
  
    address[] approved_part_addr_purchaseCar;
    address[] approved_part_addr_sellProposal;
    address[] approved_part_addr_setDriver;
    
    address payable manager;
    uint contractBalance;
    uint beginning_etc;
    uint profit;
    
    struct Dealer {
        address payable addr;
        uint dealer_balance;
    }
    Dealer setted_dealer;
    
    struct Car {
        uint carID;
        uint carPrice;
        uint offerValidTime;
    }
    Car proposed_car;
    Car purcased_car;
    
    struct Driver{
        address payable addr;
        uint driver_balance;
        uint driver_salary;
    }
    Driver setted_driver;
    Driver proposed_driver;
    
    uint attendance_fee;
    uint lastPayTime_Driver;
    uint lastPayProfit;
    uint lastExpensePay_Dealer;
    uint fix_expense;
    
    
    constructor () payable public {
        manager = msg.sender;
        contractBalance += msg.value;
        beginning_etc += msg.value;
        
        
        fix_expense = 10 wei;
        attendance_fee = 100 wei;
        lastPayProfit = now;
    }   
   
   function DispTotalBalance() private view returns(uint){
       return contractBalance;
   }
   
   
   /*
        For participant who want to join 
        must call this function
        msg.value should be setted equal or greater than participation fee
   */
    function Join() payable public {
        require(isParticipant(msg.sender) ==  true);
        require(msg.value >= attendance_fee && msg.value >= attendance_fee && addresses_participant.length < 9);
        balances_participant[msg.sender] = msg.value - attendance_fee;
        
        addresses_participant.push(msg.sender);
        contractBalance += attendance_fee;
    }
    
    
    /*
        Only manager can be caller of this function
        Manager sets the car dealer’s address and balance 
        first parameter indicates address of driver that will be setted
    */
    function SetCarDealer(address payable _address) public returns(address) {
        require(msg.sender == manager, "Must call by manager");
        setted_dealer.addr = _address;
        setted_dealer.dealer_balance = 0 wei;
        lastExpensePay_Dealer = now;
        
        return setted_dealer.addr;
    } 
    
    /*
        Manager can call this function, 
        sends the CarDealer the price of the proposed car 
        if the offer valid time is not passed yet and 
        approval state is approved by more than half of the participants.
        _ID : id of the proposed car
        _price : specified price of the proposed car
        _offerValidTime : valid time period for this car
    
    */
    function ProposeCarToBusiness(uint _ID, uint _price, uint _offerValidTime)  public returns(uint){
        require(msg.sender == setted_dealer.addr , "Must call by dealer");
        require(numDigits(_ID) == 32, "ID must be 32 digit");
        proposed_car = Car({carID : _ID , 
                        carPrice : _price , 
                        offerValidTime : now + _offerValidTime * 1 days 
                    });
       return proposed_car.carID;
    }
    
    /*
        This function is for calculating number of digit 
        _number : intended number to be calculated
    */
    function numDigits(uint _number) private pure returns (uint) {
        uint digits = 0;
        while (_number != 0) { _number /= 10; digits++; }
        return digits;
    }
    
    /*
        This function is for determining if account 
        that specified with address is participant or not
        _adrr : address of intended account
    */
    function isParticipant(address _adrr) private view returns(bool){
        bool res = false;
        for(uint i=0 ; i<addresses_participant.length ; i++){
            if(_adrr == addresses_participant[i])
                return true;
        }
        return res;
    }
    
    
    /*
        Only participants can call this function, 
        approves the proposed purchase with incrementing the approval state. 
        Each participant can increment once.
    */
    function ApprovePurchaseCar() public {
        require(isParticipant(msg.sender) == true, "Must call by participant");
        bool approved_before = false;
        for (uint i = 0; i < approved_part_addr_purchaseCar.length; i++ )
            if(approved_part_addr_purchaseCar[i] == msg.sender){
                approved_before = true;
                break;
            }
        require(approved_before == false, "This participant approved before");
        approved_part_addr_purchaseCar.push(msg.sender);
    }
    
    
    /*
        Only manager can call this function,
        sends the car dealer the price of the proposed car if the 
        offer valid time is not passed yet and 
        approval state is approved by more than half of the participants.
    */
    function PurchaseCar() public returns(uint){
        require(msg.sender == manager, "Must call by manager");
        require(now < proposed_car.offerValidTime , "Valid time is expired");
        require(approved_part_addr_purchaseCar.length >= addresses_participant.length/2);
        require(contractBalance >= proposed_car.carPrice , "No enough money for purchase this car");
        
        purcased_car.carID = proposed_car.carID;
        purcased_car.carPrice = proposed_car.carPrice;
        purcased_car.offerValidTime = proposed_car.offerValidTime;
        
        contractBalance -= purcased_car.carPrice;
        
        if (address(this).balance >= proposed_car.carPrice){
            contractBalance -= proposed_car.carPrice;
            if(!(setted_dealer.addr).send(proposed_car.carPrice)){
                contractBalance += proposed_car.carPrice ;
            }
        }
        
        setted_dealer.dealer_balance += purcased_car.carPrice;
        return setted_dealer.dealer_balance;
    }
    
    /*
        Only car dealer can call this, 
        sets proposed purchase values, such as car ID, price, 
        offer valid time and approval state (to 0)
        _price : price of proposed car
        _offerValidTime : valid time internal of proposed car
    */
    function RepurcaseCarPropose(uint _price, uint _offerValidTime) public {
        require(msg.sender == setted_dealer.addr , "Must call by dealer");
        
        purcased_car.carPrice = _price;
        purcased_car.offerValidTime = now + _offerValidTime * 1 days;
        
    }
    
    /*
        Participants can call this function, 
        approves the proposed sell with incrementing the approval state.
        Each participant can increment once.
    */
    function ApproveSellProposal() public{
        require(isParticipant(msg.sender) == true, "Must call by participant");
        bool approved_before = false;
        for (uint i = 0; i < approved_part_addr_sellProposal.length; i++ )
            if(approved_part_addr_sellProposal[i] == msg.sender){
                approved_before = true;
                break;
            }
        require(approved_before == false, "This participant approved before");
        approved_part_addr_sellProposal.push(msg.sender);
    }
    
    
    /*
        Only car dealer can call this function, 
        sends the proposed car price to contract if the offer valid time is not passed yet and 
        approval state is approved by more than half of the participants.
    */
    function RepurchaseCar() public {
        require(msg.sender == setted_dealer.addr , "Must call by dealer");
        require(approved_part_addr_sellProposal.length >= addresses_participant.length/2 , "No enough approve.");
        require(now < proposed_car.offerValidTime , "Valid time is expired");
        
        balances_participant[msg.sender] -=  purcased_car.carPrice;
        contractBalance += purcased_car.carPrice;
    }
    
    /*
        Only manager can call this function, 
        sets driver address, and salary for propose a driver.
    */
    function ProposeDriver(address payable _address, uint _salary) public{
        require(msg.sender == manager, "Must call by manager");
        proposed_driver.addr = _address;
        proposed_driver.driver_salary = _salary;
    }
    
    
    /*
        Participants can call this function, 
        approves the proposed driver with incrementing the approval state.
        Each participant can increment once.
    */
    function ApproveDriver() public{
        require(isParticipant(msg.sender) == true, "Must call by participant");
        bool approved_before = false;
        for (uint i = 0; i < approved_part_addr_setDriver.length; i++ )
            if(approved_part_addr_setDriver[i] == msg.sender){
                approved_before = true;
                break;
            }
        require(approved_before == false, "This participant approved before");
        approved_part_addr_setDriver.push(msg.sender);
    }
    
    /*
        Only manager can call this function, 
        sets the driver informations 
        if approval state is approved by more than half of the participants. 
        Assumes there is only 1 driver.
    */
    function SetDriver() public returns(address) {
        require(msg.sender == manager, "Must call by manager");
        require(approved_part_addr_setDriver.length >= addresses_participant.length/2 , "No enough approve.");
        
        setted_driver.addr = proposed_driver.addr;
        setted_driver.driver_salary = proposed_driver.driver_salary; // decided by me.
        setted_driver.driver_balance = 0 wei;
        
        lastPayTime_Driver = now;
        return setted_driver.addr;
    }
    
    
   /*
        Only manager can call this function, 
        gives the full month of salary to current driver’s account and 
        fires the driver by changing the address.
   */
   function FireDriver() public {
       require(msg.sender == manager, "Must call by manager");
       contractBalance-=setted_driver.driver_salary;
       (setted_driver.addr).transfer(setted_driver.driver_salary);
       
       if (address(this).balance >= setted_driver.driver_salary){
            contractBalance -= setted_driver.driver_salary;
            if(!(setted_driver.addr).send(setted_driver.driver_salary)){
                contractBalance += setted_driver.driver_salary ;
            }
        }
      
       setted_driver.addr = address(0);
       setted_driver.driver_salary = 0;
    //   setted_driver.driver_balance = 0;
   }
    
    /*
        Customers who use the taxi pays their ticket to contract through this function. 
    */
    function GetCharge() public payable{
        contractBalance += msg.value;
    }
    
    
    /*
        Only manager can call this function, 
        releases the salary of the driver to his/her account monthly. 
        Manager shouldn't this function more than once in a month.
    */
    function ReleaseSalary() public {
        require(msg.sender == manager, "Must call by manager");
        require(lastPayTime_Driver + 30 days < now , "Not passed one month after last payment");
        require(setted_driver.addr != address(0), "There is no driver setted");
        
        contractBalance -= setted_driver.driver_salary;
        setted_driver.driver_balance += setted_driver.driver_salary;
        
        lastPayTime_Driver = now;
    }
    
    
    /*
        Only driver can call this function, 
        if there is any money in driver’s account, 
        it will be sent to his/her address.
    */
    function GetSalary() public{
        require(msg.sender == setted_driver.addr , "Must call by driver");
        
        if (address(this).balance >= setted_driver.driver_salary){
            contractBalance -= setted_driver.driver_salary;
            if(!(setted_driver.addr).send(setted_driver.driver_salary)){
                contractBalance += setted_driver.driver_salary ;
            }
        }
    }
    
    /*
        Only Manager can call this function, 
        sends the car dealer the price of the expenses every 6 month
        Manager shouldn't call this function more than once in the last 6 months.
    */
    function CarExpenses() public{
        require(msg.sender == manager, "Must call by manager");
        require(lastExpensePay_Dealer + 180 days < now , "Not passed six month after last expense payment");
        
        if (address(this).balance >= fix_expense){
            contractBalance -= fix_expense;
            if(!(setted_dealer.addr).send(fix_expense)){
                contractBalance += fix_expense;
            }
        }
        lastExpensePay_Dealer = now;
    }
    
    
    /*
        Only Manager can call this function, 
        calculates the total profit after expenses and driver salaries,
        calculates the profit per participant and releases this amount to participants in every 6 month.
        Manager shouldn't call this function more than once in the last 6 months.
    */
    function PayDividend() public{
        require(msg.sender == manager, "Must call by manager");
        require(lastPayProfit + 180 days < now , "Not passed six month after last profit payment");
        
        profit = contractBalance - beginning_etc;
        uint profit_per_participant;
        if(profit>0)
           profit_per_participant =  profit/(addresses_participant.length);
           
        for(uint i = 0; i < addresses_participant.length; i += 1){
             if(contractBalance >= profit_per_participant){
                account_participant[addresses_participant[i]] += profit_per_participant;
                contractBalance -= profit_per_participant;
             }
            
        }
        
    }
    
    /*
        Only Participants can call this function, 
        if there is any money in participants’ account, 
        it will be send to his/her address.
    */
    function GetDivident() public{
        require(isParticipant(msg.sender) == true, "Must call by participant");
        
        msg.sender.transfer(account_participant[msg.sender]);
        account_participant[msg.sender] = 0;
    }
    
}