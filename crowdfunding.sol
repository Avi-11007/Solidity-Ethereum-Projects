// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0 < 0.9.0;
contract crowdfunding
{
    mapping(address=>uint) public contributors;
    address public managers;
    uint public minimumcontribution;
    uint public deadline;
    uint public target;
    uint public raisedamount;
    uint public noofcontributors;
    struct request{
        string description;
        address payable receipient;
        uint value;
        uint noofvoters;
        bool completed;
        mapping(address=>bool) voters;
    }
    mapping(uint=>request) public requests;
    uint public numrequests;
    constructor(uint _target,uint _deadline)
    {
        target=_target;
        deadline=block.timestamp+_deadline;
        minimumcontribution=100 wei;
        managers=msg.sender;
}
function sendEth() public payable
{
require(block.timestamp<deadline,"Deadline has passed");
require(msg.value>=minimumcontribution,"Minimum contribution is not met");
if(contributors[msg.sender]==0){
    noofcontributors++;
}
contributors[msg.sender]+=msg.value;
raisedamount+=msg.value;
}
function getcontractbal() public view returns(uint)
{
    return address(this).balance;
}
function refund() public {
    require(block.timestamp>deadline && raisedamount>target,"you are not eligible");
    require(contributors[msg.sender]>0);
    address payable user=payable(msg.sender);
    user.transfer(contributors[msg.sender]);
    contributors[msg.sender]=0;
}
modifier onlymanager(){
    require(msg.sender==managers,"only manager can call this function");
    _;
}
function createrequests(string memory _description,address payable _receipient,uint _value) public onlymanager
{
request storage newrequests=requests[numrequests];
numrequests++;
newrequests.description=_description;
newrequests.receipient=_receipient;
newrequests.value=_value;
newrequests.completed=false;
newrequests.noofvoters=0;

}
function voterequest(uint _requestno) public{
    require(contributors[msg.sender]>0,"you must be a contributor first");
    request storage thisrequest=requests[_requestno];
    require(thisrequest.voters[msg.sender]==false,"You have already voted");
    thisrequest.voters[msg.sender]==true;
    thisrequest.noofvoters++;
}
function makepayment(uint _requestno) public onlymanager{
    require(raisedamount>=target,"target missed");
    request storage thisrequest=requests[_requestno];
    require(thisrequest.completed==false,"the request has been completed");
    require(thisrequest.noofvoters>noofcontributors/2,"majoority does not support you");
    thisrequest.receipient.transfer(thisrequest.value);
    thisrequest.completed=true;

}
}