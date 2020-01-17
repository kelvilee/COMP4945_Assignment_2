drop table Customer;
drop table Employee;
drop table ServiceType;
drop table CustomerService;
drop table CustomerServiceSchedule;

drop table CustomerServiceScheduleFacts;
drop table EmployeeDim;
drop table ServiceDim;
drop table CustomerDim;
drop table ShiftDim;
drop table AddressDim;

create table Customer (
	ID RAW(32),
	Name char(80), 
	Address char(80), 
	Birthdate date, 
	Picture blob, 
	Gender char(1)
);
create table Employee (
	ID RAW(32),
	Name char(80),
	Address char(80),
	ManagerID RAW(32),
	JobTitle char(80), 
	CertifiedFor char(80), 
	StartDate date, 
	Salary integer
);
create table ServiceType (
	ID RAW(32), 
	Name char(80), 
	CertificationRqts integer, 
	Rate integer
);
create table CustomerService(
	ID RAW(32),
	CustomerID RAW(32), 
	ServiceTypeID RAW(32), 
	ExpectedDuration integer
); 
create table CustomerServiceSchedule(
	ID RAW(32),
	CustomerServiceID RAW(32), 
	EmployeeID RAW(32), 
	StartDateTime date, 
	ActualDuration integer, 
	Status NUMBER(1, 0)
);

create table CustomerServiceScheduleFacts (
	ID RAW(32),
	EmployeeID RAW(32),
	CustomerID RAW(32),
	ServiceID RAW(32),
	AddressID RAW(32),
	ShiftID RAW(32),
	ActualDuration integer,
	Status NUMBER(1, 0)
);
create table CustomerDim (
	ID RAW(32),
	Name char(80),
	Age integer,
	Gender char(1)
);
create table EmployeeDim (
	ID RAW(32),
	Name char(80)
);
create table ServiceDim (
	ID RAW(32),
	Name char(80),
	CertificationRqts integer,
	Rate integer
);
create table AddressDim (
	ID RAW(32),
	City char(80)
); 
create table ShiftDim (
	ID RAW(32),
	DayOfWeek integer
);

insert into ShiftDim values (SYS_GUID(), 1);
insert into ShiftDim values (SYS_GUID(), 2);
insert into ShiftDim values (SYS_GUID(), 3);
insert into ShiftDim values (SYS_GUID(), 4);
insert into ShiftDim values (SYS_GUID(), 5);
insert into ShiftDim values (SYS_GUID(), 6);
insert into ShiftDim values (SYS_GUID(), 7);

insert into AddressDim values (SYS_GUID(), 'Burnaby');
insert into AddressDim values (SYS_GUID(), 'Surrey');
insert into AddressDim values (SYS_GUID(), 'Vancouver');
insert into AddressDim values (SYS_GUID(), 'Delta');
insert into AddressDim values (SYS_GUID(), 'Coquitlam');

create or replace trigger update_employee before insert or update on Employee for each row
begin
	if inserting then
		insert into EmployeeDim (ID, Name) values (:new.ID, :new.Name);
	elsif updating then
		update EmployeeDim set Name = :new.Name where ID = :new.ID;	
	end if;
end;
/
show errors;

create or replace trigger update_customer before insert or update on Customer for each row
begin
	if inserting then
		insert into CustomerDim (ID, Name, Age, Gender) values (:new.ID, :new.Name, TRUNC((SYSDATE - :new.Birthdate)/365.25), :new.Gender);
	elsif updating then
		update CustomerDim set Name = :new.Name, Age = TRUNC((SYSDATE - :new.Birthdate)/365.25), Gender = :new.Gender where ID = :new.ID;	
	end if;
end;
/
show errors;

create or replace trigger update_service before insert or update on ServiceType for each row
begin
	if inserting then
		insert into ServiceDim (ID, Name, CertificationRqts, Rate) values (:new.ID, :new.Name, :new.CertificationRqts, :new.Rate);
	elsif updating then
		update ServiceDim set Name = :new.Name, CertificationRqts = :new.CertificationRqts, Rate = :new.Rate where ID = :new.ID;	
	end if;
end;
/
show errors;

create or replace trigger update_service_schedule before insert or update on CustomerServiceSchedule for each row
declare
	myCID RAW(32);
	myAddress char(80);
	mySID RAW(32);
	myAID RAW(32);
	mySHID RAW(32);

begin
	if inserting then
	
		select CustomerService.ServiceTypeID, CustomerService.CustomerID
		into mySID, myCID
		from CustomerService
		where ID = :new.CustomerServiceID;
	
		select Customer.Address
		into myAddress
		from Customer
		where ID = myCID;
		
		select AddressDim.ID
		into myAID
		from AddressDim
		where City = myAddress;
		
		select ShiftDim.ID
		into mySHID
		from ShiftDim
		where to_char(:new.StartDateTime, 'D') = DayOfWeek;
	
		insert into CustomerServiceScheduleFacts (ID, EmployeeID, CustomerID, ServiceID, AddressID, ShiftID, ActualDuration, Status)
		values (:new.ID, :new.EmployeeID, myCID, mySID, myAID, mySHID, :new.ActualDuration, :new.Status);
	elsif updating then
	
		select CustomerService.ServiceTypeID, CustomerService.CustomerID
		into mySID, myCID
		from CustomerService
		where ID = :new.CustomerServiceID;
	
		select Customer.Address
		into myAddress
		from Customer
		where ID = myCID;
		
		select AddressDim.ID
		into myAID
		from AddressDim
		where City = myAddress;
		
		select ShiftDim.ID
		into mySHID
		from ShiftDim
		where to_char(:new.StartDateTime, 'D') = DayOfWeek;
	
		update CustomerServiceScheduleFacts set EmployeeID = :new.EmployeeID, CustomerID = myCID, ServiceID = mySID, AddressID = myAID, ShiftID = mySHID, ActualDuration = :new.ActualDuration, Status = :new.Status where ID = :new.ID;	
	end if;
end;
/
show errors;

create or replace procedure insertEmpDim as
cursor c1 is select ID, Name from Employee;
myID RAW(32);
myName char(80);
begin

open c1;
loop
fetch c1 into myID, myName;
exit when c1%notfound;
insert into EmployeeDim(ID, Name) values (myID, myName);
end loop;
close c1;
end;
/

create or replace procedure insertCustDim as
cursor c1 is select ID, Name, Birthdate, Gender from Customer;
myID RAW(32);
myName char(80);
myDate date;
myGender char(1);
begin

open c1;
loop
fetch c1 into myID, myName, myDate, myGender;
exit when c1%notfound;
insert into CustomerDim(ID, Name, Age, Gender) values (myID, myName, TRUNC ((SYSDATE - myDate)/365.25), myGender);
end loop;
close c1;
end;
/

create or replace procedure insertServDim as
cursor c1 is select ID, Name, CertificationRqts, Rate from ServiceType;
myID RAW(32);
myName char(80);
myCertificationRqts integer;
myRate integer;
begin

open c1;
loop
fetch c1 into myID, myName, myCertificationRqts, myRate;
exit when c1%notfound;
insert into ServiceDim(ID, Name, CertificationRqts, Rate) values (myID, myName, myCertificationRqts, myRate);
end loop;
close c1;
end;
/