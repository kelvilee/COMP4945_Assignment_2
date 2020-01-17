// example
drop table student;
drop table courses;
drop table assignments;
create table student (sid integer, sname char(80), saddress char(80), gpa integer);
create table courses (sid integer, cid integer, cgrade integer);
create table assignments ( sid integer, cid integer, aid integer, agrade integer);

// real
drop table Customer;
drop table Employee;
drop table ServiceType;
drop table CustomerService;
drop table CustomerServiceSchedule;

drop table ClientServiceScheduleFacts;
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
	CustomerID RAW(32), 
	ServiceTypeID RAW(32), 
	ExpectedDuration integer
); 
create table CustomerServiceSchedule(
	CustomerID RAW(32), 
	ServiceTypeID RAW(32), 
	EmployeeID RAW(32), 
	StartDateTime date, 
	ActualDuration integer, 
	Status NUMBER(1, 0)
);

create table CustomerServiceScheduleFacts (
	ID RAW(32),
	EmployeeID RAW(32),
	ClientID RAW(32),
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
	CityArea char(80),
	City char(80),
	Region char(80)
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

insert into AddressDim values (SYS_GUID(), 'North', 'Burnaby', 'LM');
insert into AddressDim values (SYS_GUID(), 'South', 'Burnaby', 'LM');
insert into AddressDim values (SYS_GUID(), 'Fleetwood', 'Surrey', 'LM');
insert into AddressDim values (SYS_GUID(), 'Newton', 'Surrey', 'LM');
insert into AddressDim values (SYS_GUID(), 'South', 'Surrey', 'LM');

create or replace trigger update_course_grades before insert or update of agrade or delete on assignments for each row
begin
	if inserting then
		update courses set cgrade = cgrade + :new.agrade where sid = :new.sid and cid = :new.cid;
	elsif updating then
		update courses set cgrade = cgrade + (:new.agrade - :old.agrade) where sid = :new.sid and cid = :new.cid;	
	elsif deleting then
		update courses set cgrade = cgrade - :old.agrade where sid = :old.sid and cid = :old.cid;
	end if;
end;
/
show errors;

create or replace procedure createStudent as 
begin
insert into student (sid, sname, saddress, gpa) values (1, 'John', 'Surrey', 80);
end;
/
select * from student;
execute createstudent;
select * from student;
insert into courses values(1, 4945, 0);

select * from courses;

insert into assignments values(1, 4945, 1, 75);
insert into assignments values(1, 4945, 2, 80);
insert into assignments values(1, 4945, 3, 85);

select * from courses;

create or replace procedure updategrades as
cursor c1 is select sid, cid, sum(agrade)/count(agrade) from assignments group by sid, cid;
mysid integer;
mycid integer;
mycgrade integer;
begin

open c1;
loop
fetch c1 into mysid, mycid, mycgrade;
exit when c1%notfound;
update courses set cgrade = mycgrade where sid = mysid and cid = mycid;
end loop;
close c1;
end;
/
show errors;
select * from courses;
execute updategrades;
select * from courses;

create or replace procedure selectstudent(stdid IN integer, myName out varchar2) as
begin
	select sname into myName from student where sid = stdid;
end;
/

show errors;
variable myName char(80);
execute selectstudent(1, :myName);
print myName;
