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
insert into CustomerDim(ID, Name, Age, Gender) values (myID, myName, TRUNC ((SYSDATE - TO_DATE('1990-09-09'))/365.25), myGender);
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
create or replace procedure insertAddrDim as
begin
insert into AddressDim (ID, CityArea, City, Region) values (SYS_GUID(), 'South', 'Surrey', 'LM');
insert into AddressDim (ID, CityArea, City, Region) values (SYS_GUID(), 'North', 'Surrey', 'LM');
insert into AddressDim (ID, CityArea, City, Region) values (SYS_GUID(), 'South', 'Surrey', 'LM');
insert into AddressDim (ID, CityArea, City, Region) values (SYS_GUID(), 'Newton', 'Surrey', 'LM');
insert into AddressDim (ID, CityArea, City, Region) values (SYS_GUID(), 'North', 'Surrey', 'LM');
end;
/

create or replace procedure insertShiftDim as
begin
insert into ShiftDim (ID, DayOfWeek) values (SYS_GUID(), 1);
insert into ShiftDim (ID, DayOfWeek) values (SYS_GUID(), 6);
insert into ShiftDim (ID, DayOfWeek) values (SYS_GUID(), 2);
insert into ShiftDim (ID, DayOfWeek) values (SYS_GUID(), 4);
insert into ShiftDim (ID, DayOfWeek) values (SYS_GUID(), 5);
end;
/

