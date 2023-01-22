-- Q1.	Create DataBase PROJECT and Write SQL query to create above schema with constraints


create database project;
use project;

create table Branch_mstr
(
branch_no int primary key,
name char(50) not null
);

create table employee
(
emp_no int primary key,
branch_no int,
fname char(20),
mname char(20),
lname char(20),
dept char(20),
desig char(10),
mngr_no int not null,
foreign key(branch_no) references Branch_mstr(branch_no)
);

create table customer
(
custid int primary key,
fname char(30),
mname char(30),
lname char(30),
occupation char(10),
dob date
);

drop table customer;
create table account
(
acnumber int primary key,
custid int not null,
bid int not null,
curbal int,
opnDT date,
atype char(10),
astatus char(10)
);

-- Q2. Inserting records into created tables.

insert into branch_mstr values
(1,'Delhi'),
(2,'Mumbai');

select * from branch_mstr;

insert into customer values
(1,'Ramesh','Chandra','Sharma','Service','1976-12-06'),
(2,'Avinash','Sunder','Minha','Business','1974-10-16');

select * from customer;

insert into account values
(1,1,1,10000,'2012-12-15','Saving','Active'),
(2,2,2,5000,'2012-06-12','Saving','Active');

select * from account;

insert into employee values
(1,1,'Mark','Steve','Lara','Account','Accountant',2),
(2,2,'Bella','James','Ronald','Loan','Manager',1);

select * from employee;

-- Q3. Select unique occupation from customer table.

select * from customer;

select occupation from customer;

-- Q4. Sort accounts according to current balance.

select * from account;

select curbal,acnumber,custid,bid,opndt,atype,astatus from account order by curbal desc;

-- Q5. Find the date of birth of customer name 'Ramesh'.

select * from customer;

select dob from customer where fname='Ramesh';

-- Q6. Add column city to branch table.

alter table branch_mstr add column city varchar(20);

select * from branch_mstr;

-- Q7. Update the mname and lname of employee 'Bella' and set to 'Karan','Singh'.

update employee set mname='Karan' where fname='Bella';
update employee set lname='Singh' where fname='Bella';

select * from employee;

-- Q8. Select accounts opened between '2012-07-01' AND '2013-01-01'.

select * from account;

select * from account where opndt between '2012-07-01' AND '2013-01-01';

-- Q9. List the names of customers having ‘a’ as the second letter in their names.

select * from customer;

select * from customer where fname like '_a%';

-- Q10. Find the lowest balance from customer and account table.

select * from customer;
select * from account;

select a.custid,fname,lname,occupation,dob,acnumber,bid,min(curbal) least_balance,opndt,atype,astatus
from customer c join account a
using(custid);

-- Q11. Give the count of customer for each occupation.

select * from customer;

select occupation,count(distinct occupation) occupation_cnt from customer group by occupation;

-- Q12.	Write a query to find the name (first_name, last_name) of the employees who are managers.

select * from employee;

select e2.emp_no,e2.fname,e2.lname,e2.mngr_no
from employee e1 join employee e2
where e2.emp_no=e1.mngr_no;

# or

select e1.fname,e2.fname as Manager_Name
from employee e1 left join employee e2
on e1.mngr_no=e2.emp_no;

-- Q13.	List name of all employees whose name ends with a.

select * from employee;

select * from employee where fname like '%a';

-- Q14.	Select the details of the employee who work either for department ‘loan’ or ‘credit’.

select * from employee;

select * from employee where dept in('loan','credit');

-- Q15.	Write a query to display the customer number, customer firstname, account number for the customers who are botn after 15th of any 
--      month.


select * from customer;
select * from account;

select c.custid,c.fname,a.acnumber,dob,day(dob) day_of_birth
from customer c join account a
using(custid)
where day(dob)<15;

-- Q16.	Write a query to display the customer’s number, customer’s firstname, branch id and balance amount for people using JOIN.

select * from customer;
select * from account;

select c.custid,fname,bid,curbal 
from customer c join account a
using(custid);

-- Q17.	Create a virtual table to store the customers who are having the accounts in the same city as they live.

select * from account;
select * from branch_mstr;
select * from customer;

# creating new attribute city in customer table, which shows his city of residence.

select * from customer;

alter table customer add column city varchar(15);

# Now adding some values in branch_mstr and customer table

select * from customer;
select * from branch_mstr;

update branch_mstr set city='Delhi' where branch_no=1;
update branch_mstr set city='Mumbai' where branch_no=2;

update customer set city='Mumbai' where custid=1;
update customer set city='Mumbai' where custid=2;

select * from customer;
select * from branch_mstr;
select * from account;

alter table customer rename column city to city_of_residence;

create view customers_city as
(select a.custid,fname,lname,city_of_residence,name,city,acnumber,bid,curbal,atype,astatus
from customer a join account b
using(custid)
join branch_mstr c
on b.bid=c.branch_no
where a.city_of_residence=city);


-- Q18.	A. Create a transaction table with following details 
-- TID – transaction ID – Primary key with autoincrement 
-- Custid – customer id (reference from customer table
-- account no – acoount number (references account table)
-- bid – Branch id – references branch table
-- amount – amount in numbers
-- type – type of transaction (Withdraw or deposit)
-- DOT -  date of transaction



create table transactions
(
tid int primary key auto_increment,
custid int,
account_no int,
bid int,
amount int,
t_type char(8) check(t_type in('Withdraw','Deposit')),
dot date,
constraint fk_1 foreign key(custid) references customer(custid),
constraint fk_2 foreign key(account_no) references account(acnumber),
constraint fk_3 foreign key(bid) references branch_mstr(branch_no)
);

alter table transactions modify column dot datetime;

desc transactions;
select * from transactions;

-- a. Write trigger to update balance in account table on Deposit or Withdraw in transaction table.


DELIMITER //
create trigger transaction_details
after insert on transactions
for each row
begin
if new.t_type = 'Deposit' then update account set curbal = curbal+new.amount where custid=new.custid ;
elseif new.t_type = 'Withdraw' then update account set curbal = curbal-new.amount where custid=new.custid ;
end if;
end // 
DELIMITER ;

-- b. Insert values in transaction table to show trigger success.

select * from transactions;

insert into transactions values 
(1,1,1,1,2000,'deposit',now());

insert into transactions values 
(2,2,2,2,3000,'withdraw',now());

-- Q19.	Write a query to display the details of customer with second highest balance 

select * from customer;
select * from account;

select fname,t.custid,acnumber,atype,astatus,curbal from customer c
join
(select custid,acnumber,atype,astatus,curbal from account order by curbal desc limit 1,1)t
on c.custid=t.custid;

-- Q20.	Take backup of the databse created in this case study.

# 1. Backup of database taken using the server option.
# 2. Using data export in server menu.
# 3. A dump folder was created 1st for the database created 'project'.
# 4. A dump file was created after creating a dump folder. 
# 5. The backup of data base can be accessed using any of the 2 options.
# 6. Using data import in server option will help in fetching our backup dumps.

#B Create customer schema with following commands

create database casestudy;
use casestudy;

DROP TABLE IF EXISTS  ORDER_ITEMS;
  DROP TABLE IF EXISTS  CARTON;
  DROP TABLE IF EXISTS  ORDER_HEADER;
  DROP TABLE IF EXISTS  ONLINE_CUSTOMER;
  DROP TABLE IF EXISTS  SHIPPER;
  DROP TABLE IF EXISTS  ADDRESS;
  DROP TABLE IF EXISTS  PRODUCT;
  DROP TABLE IF EXISTS  PRODUCT_CLASS;
  
  
  CREATE TABLE ADDRESS 
   (	ADDRESS_ID INT(6), 
		ADDRESS_LINE1 VARCHAR(50), 
		ADDRESS_LINE2 VARCHAR(50), 
		CITY VARCHAR(30), 
		STATE VARCHAR(30), 
		PINCODE INT(6), 
		COUNTRY VARCHAR(30)
   ) ;
   
   #-------------------------------------------------------
#--  DDL for Table CARTON
#-------------------------------------------------------

  CREATE TABLE CARTON 
   (	CARTON_ID INT(6), 
		LEN BIGINT(10), 
		WIDTH BIGINT(10),
		HEIGHT BIGINT(10)
   ) ;
#-------------------------------------------------------
#--  DDL for Table ONLINE_CUSTOMER
#-------------------------------------------------------

  CREATE TABLE ONLINE_CUSTOMER 
   (	CUSTOMER_ID INT(6), 
		CUSTOMER_FNAME VARCHAR(20), 
		CUSTOMER_LNAME VARCHAR(20), 
		CUSTOMER_EMAIL VARCHAR(30), 
		CUSTOMER_PHONE BIGINT(10), 
		ADDRESS_ID INT(6), 
		CUSTOMER_CREATION_DATE DATE, 
		CUSTOMER_USERNAME VARCHAR(20), 
		CUSTOMER_GENDER CHAR(1)
   ) ;
#-------------------------------------------------------
#--  DDL for Table ORDER_HEADER
#-------------------------------------------------------

  CREATE TABLE ORDER_HEADER 
   (	ORDER_ID INT(6), 
		CUSTOMER_ID INT(6), 
		ORDER_DATE DATE, 
		ORDER_STATUS VARCHAR(10), 
		PAYMENT_MODE VARCHAR(20), 
		PAYMENT_DATE DATE, 
		ORDER_SHIPMENT_DATE DATE, 
		SHIPPER_ID INT(6)
   ) ;
#-------------------------------------------------------
#--  DDL for Table ORDER_ITEMS
#-------------------------------------------------------

  CREATE TABLE ORDER_ITEMS 
   (	ORDER_ID INT(6), 
		PRODUCT_ID INT(6), 
		PRODUCT_QUANTITY INT(3)
   ) ;
#-------------------------------------------------------
#--  DDL for Table PRODUCT
#-------------------------------------------------------

  CREATE TABLE PRODUCT 
   (	PRODUCT_ID INT(6), 
		PRODUCT_DESC VARCHAR(60), 
		PRODUCT_CLASS_CODE INT(4), 
		PRODUCT_PRICE DECIMAL(12,2), 
		PRODUCT_QUANTITY_AVAIL INT(4), 
		LEN INT(5), 
		WIDTH INT(5), 
		HEIGHT INT(5), 
		WEIGHT DECIMAL(10,4)
   ) ;
#-------------------------------------------------------
#--  DDL for Table PRODUCT_CLASS
#-------------------------------------------------------

  CREATE TABLE PRODUCT_CLASS 
   (	PRODUCT_CLASS_CODE INT(4), 
		PRODUCT_CLASS_DESC VARCHAR(40)
   ) ;
#-------------------------------------------------------
#--  DDL for Table SHIPPER
#-------------------------------------------------------

  CREATE TABLE SHIPPER 
   (	SHIPPER_ID INT(6), 
		SHIPPER_NAME VARCHAR(30), 
		SHIPPER_PHONE BIGINT(12), 
		SHIPPER_ADDRESS INT(6)
   ) ;

# INSERTING into ADDRESS

Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (909,'H.NO.16, Sector-4, 14th Cross','Near BDA Complex, HSR Layout','Bangalore','Karnataka',560172,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (910,'H.NO.15, Sector-5, 7th Main','HSR Layout','Bangalore','Karnataka',560172,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (911,'Flat-8, 2689/29','Tuglakkabad extn','New Delhi','Delhi',110019,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (912,'Flat-10, 2689/27','Nizamuddin','New Delhi','Delhi',110012,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (914,'H.NO.20,Heritage Apartments','Udayagiri','Mysore','Karnataka',570019,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (915,'2686/23, Surya Apartments','Badarpur','New Delhi','Delhi',110013,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (916,'No.188,1st Main,3rd Cross','Subramanyanagar','Bangalore','Karnataka',560021,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (917,'No.380,Sri Sai Complex','Ulsoor','Mysore','Karnataka',562109,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (918,'# 55/1,5th Cross,S.P.Road','Hosur','Hosur','Tamilnadu',635235,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (919,'43/3,Mukesh Complex','Madanayakanapalli','Hyderabad','Andhra Pradesh',517247,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (920,'824/1,Krishna Complex','Bagalpur Circle','Krishnagiri','Tamilnadu',635109,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (921,'162/S2,Margosa Road,','Malleswaram','Bangalore','Karnataka',560003,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (922,'No.65,9th Main,Begur Road','Bommanhalli','Mysore','Karnataka',570019,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (923,'#52,N.K.Building','Bijai','Mangalore','Karnataka',575002,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (924,'1160,Rainbow Apartments','Parangipalyam','Chittoor','Andhra Pradesh',517337,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (925,'No.1610,Kuppu Swamy Complex','SVR Layout','Salem','Tamilnadu',635203,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (926,'#140,4th Main,6th Cross','Manikonda IT Park','Hyderabad','Andhra Pradesh',517252,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (927,'#155, 2nd Main Channal Road','Saraswethipuram','Dharmapuri','Tamilnadu',635897,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (928,'#412, 100ft Road,4th Block','Koramangala','Bangalore','Karnataka',560034,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (913,'No. 354, 3/5/343','1st Main, 2nd Cross, Jayanagar 4th Blk','Bangalore','Karnataka',560005,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (1000,'Anand Engineering, Plot No. 66, Road No. 15/17','MIDC, Andheri East, ','Mumbai','Maharashtra',400093,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (1001,'59-A, Road INT 1, ','Mulgaon, Andheri East,','Mumbai','Maharashtra',400047,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (1002,'Acme Plaza, Andheri - Kurla Rd, ','Vijay Nagar Colony, J B Nagar, Andheri East,','Mumbai','Maharashtra',400053,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (1003,'#41, Main Road,4th Block','Opp. Forum Mall, Koramangala','Bangalore','Karnataka',560034,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (1004,'Collector Chawl, Kondivita Road, ','J B Nagar, Andheri East','Mumbai','Maharashtra',400059,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (1005,'Jeevan Sandhya CHS, Bharat Ark, 4, Veera Desa#6','Mhada Colony, Azad Nagar, Andheri West','Mumbai','Maharashtra',400053,'India');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (930,'8340','Pilgrim Lane','Fargo','ND',58012,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (931,'938','SE. 53rd Street','Scarsdale','NY',10583,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (932,'7834','Theatre St.','Brooklyn','NY',11201,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (933,'777','Brockton Avenue','Abington','MA',2351,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (934,'30','Memorial Drive','Avon','MA',2322,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (935,'250','Hartford Avenue','Bellingham','MA',2019,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (936,'141','Washington Ave','Albany','NY',12205,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (937,'13858','Rt 31 Brookfield St','W. Alibio','NY',14411,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (938,'2055','Niagara Falls Blvd','Amherst','NY',14228,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (939,'2011','Niagara Falls Blvd','Amherst','NY',14228,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (940,'315','Foxon Blvd, New','Haven','CT',6513,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (941,'164','Danbury Rd, New','Milford','CT',6776,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (942,'3164','Berlin Turnpike','Newington','CT',6111,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (943,'474','Boston Post Road','North Windham','CT',6256,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (944,'650','Main Ave','Norwalk','CT',6851,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (945,'1600','Montclair Rd','Birmingham','AL',35210,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (946,'5919','Trussville Crossings Pkwy','Birmingham','AL',35235,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (947,'5360','Southwestern Blvd','Hamburg','NY',14075,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (948,'103','North Caroline St','Herkimer','NY',13350,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (949,'1000','State Route 36','Hornell','NY',14843,'USA');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (950,'1 Holland Grove Road','#23-34 Beachview Apts','Bukit Timah',null,278790,'Singapore');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (951,'16, Sandilands Road','#12-45 Changi Towers','Singapore',null,546080,'Singapore');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (952,'Blk 35 Mandalay Road','# 13–37 Mandalay Towers ','Singapore',null,308215,'Singapore');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (953,'10 Eunos Road 8 ','Singapore Post Centre ','Singapore',null,408600,'Singapore');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (954,'Bruderer 65 ','Loyang Way','Singapore',null,508755,'Singapore');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (955,'277 Orchard Road','Tampines','Singapore',null,238858,'Singapore');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (956,'75 Kg Sg Ramal Luar','Kajang ','Selangor',null,43000,'Malaysia');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (957,'Apt #23, Putra Towers','45 Jalan Tun Ismail ','Kuala Lumpur',null,50480,'Malaysia');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (958,'Apt #24, Putra Towers','45 Jalan Tun Ismail ','Kuala Lumpur',null,50480,'Malaysia');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (959,'476 Jalan Tun Razak','77A Jalan Sultan Sulaiman, ','Kuala Terengganu',null,20000,'Malaysia');
Insert into ADDRESS (ADDRESS_ID,ADDRESS_LINE1,ADDRESS_LINE2,CITY,STATE,PINCODE,COUNTRY) values (960,'205 Shanthi Villa','Silkhouse Street','Kandy',null,20000,'Sri Lanka');
# INSERTING into CARTON

Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (10,600,300,100);
Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (20,1200,900,450);
Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (30,1200,900,600);
Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (40,1500,900,900);
Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (50,3000,1000,900);
Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (60,300,150,50);
Insert into CARTON (CARTON_ID,LEN,WIDTH,HEIGHT) values (70,300,200,50);
# INSERTING into ONLINE_CUSTOMER

Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (1,'Jennifer','Wilson','jen_w@gmail.com',9776363306,909,str_to_date('01-JUN-91','%d-%b-%y'),'jen_w','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (2,'Jackson','Davis','dave_jack@gmail.com',9886363307,910,str_to_date('12-JUN-01','%d-%b-%y'),'dave_jack','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (3,'Komal','Choudhary','ch_komal@yahoo.co.IN',9178234526,911,str_to_date('26-JUN-02','%d-%b-%y'),'komalc','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (4,'Wilfred','Jean','w_jean@gmail.com',9196257439,912,str_to_date('12-JAN-06','%d-%b-%y'),'jeanw','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (6,'Anita','Goswami','agoswami@gmail.com',9873245623,914,str_to_date('13-MAR-06','%d-%b-%y'),'anitag','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (7,'Ashwathi','Bhatt','ash_bhat@yahoo.co.IN',9773636307,915,str_to_date('15-APR-07','%d-%b-%y'),'abhatt','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (8,'Neetha','Castelina','neetha20@gmail.com',8196236362,916,str_to_date('16-AUG-11','%d-%b-%y'),'cneeta','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (9,'Devika','Satish','devika_sa@gmail.com',9780945716,917,str_to_date('01-SEP-11','%d-%b-%y'),'sdevika','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (10,'Bidhan','C.Roy','bidhanroy@yahoo.co.in',9886218583,918,str_to_date('23-OCT-11','%d-%b-%y'),'bcroy','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (11,'Vikas','Jha','vikas.jha@gmail.com',9008812436,919,str_to_date('15-NOV-11','%d-%b-%y'),'vjha','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (12,'Arul','Kumar.T','arulkumar@gmail.com',9902179894,920,str_to_date('03-DEC-11','%d-%b-%y'),'akumar','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (13,'Ravi','Srinivasn','r_srinivasn@yahoo.co.in',9945466015,921,str_to_date('05-JAN-12','%d-%b-%y'),'ravisri','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (14,'Avinash','Dutta','avinash.dutta@yahoo.co.in',9845100228,922,str_to_date('18-JAN-12','%d-%b-%y'),'avdutta','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (15,'Jyoti','Sinha','jyotisinha@gmail.com',9987795155,923,str_to_date('31-JAN-12','%d-%b-%y'),'jyo_s','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (16,'Vijay','Bollineni','vbollineni@gmail.com',7829012228,924,str_to_date('06-FEB-12','%d-%b-%y'),'vbolli','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (17,'Prasad','Shetty','pshetty@yahoo.co.in',9731497821,925,str_to_date('26-FEB-12','%d-%b-%y'),'shetty','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (18,'Suresh','Babu','sbabu@yahoo.co.in',9845969216,926,str_to_date('01-MAR-12','%d-%b-%y'),'babu_s','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (19,'Bharti','Subhash','bhartis@gmail.com',9886870414,927,str_to_date('28-MAR-12','%d-%b-%y'),'bha_subh','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (20,'Keshav','Jog','kesjog@yahoo.co.in',7942536789,928,str_to_date('06-APR-12','%d-%b-%y'),'jog_kes','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (5,'Ramya','Ravinder','ramya_r23@gmail.com',7732341567,913,str_to_date('12-FEB-06','%d-%b-%y'),'rramya','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (21,'Alan','Silvestri','alan_silver@msn.com',9450465464,930,str_to_date('04-FEB-16','%d-%b-%y'),'asilvestri','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (22,'Andrew','Stanton','andrew_stanton@yahoo.com',9806980253,931,str_to_date('23-MAY-13','%d-%b-%y'),'astanton','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (23,'Anna','Pinnock','anna_pinnock@yahoo.com',8540548103,932,str_to_date('18-JAN-13','%d-%b-%y'),'apinnock','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (24,'Brian','Grazer','brian_grazer@gmail.com',7599462567,933,str_to_date('28-DEC-09','%d-%b-%y'),'bgrazer','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (25,'Bruno','Delbonnel','bruno_delbonnel@msn.com',9016687652,934,str_to_date('27-AUG-12','%d-%b-%y'),'bdelbonnel','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (26,'Stephen','E. Rivkin','stephen_e. rivkin@msn.com',9860111721,935,str_to_date('04-MAR-10','%d-%b-%y'),'srivkin','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (27,'Mali','Finn','mali_finn@yahoo.com',7373475035,936,str_to_date('14-JAN-06','%d-%b-%y'),'mfinn','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (28,'Sayyed','Faraj','sayyed_faraj@gmail.com',8556784235,937,str_to_date('01-NOV-09','%d-%b-%y'),'sfaraj','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (29,'Francine','Maisler','francine_maisler@gmail.com',8440046170,938,str_to_date('01-SEP-13','%d-%b-%y'),'fmaisler','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (30,'Anita','Kohli','anita_kohli@yahoo.com',8631526613,939,str_to_date('24-OCT-10','%d-%b-%y'),'akohli','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (31,'Thomas','Newman','thomas_nman@yahoo.com',9539300577,940,str_to_date('30-JUN-15','%d-%b-%y'),'tnewman','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (32,'Hans','Zimmer','hans_zimmer@yahoo.com',8338774317,941,str_to_date('24-JAN-16','%d-%b-%y'),'hzimmer','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (33,'Niseema','Zimmer','niseemaz@yahoo.com',8179413840,941,str_to_date('29-DEC-14','%d-%b-%y'),'ntalli','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (34,'Hans','Zimmer','hans_zimmer@gmail.com',9477272235,943,str_to_date('27-SEP-15','%d-%b-%y'),'hzimmer2','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (35,'Thomas','Newman','thomas_newman@gmail.com',9526577840,944,str_to_date('16-JAN-14','%d-%b-%y'),'tnewman2','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (36,'Michelle','H. Shores','howard_shores@yahoo.com',8795007592,945,str_to_date('24-JUN-10','%d-%b-%y'),'mshores','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (37,'James','Newton Howard','james_nhoward@yahoo.com',9520246368,946,str_to_date('06-JUL-12','%d-%b-%y'),'jhoward','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (38,'John','Lasseter','john_lass@gmail.com',9876356288,947,str_to_date('02-SEP-16','%d-%b-%y'),'jlasseter','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (39,'Liz','Mullane','liz_mullane@gmail.com',7859695387,948,str_to_date('29-MAR-06','%d-%b-%y'),'lmullane','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (40,'Paul','Haggis','paul_haggis@gmail.com',8332681111,949,str_to_date('31-AUG-16','%d-%b-%y'),'phaggis','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (41,'Tharman','Shanmugaratnam','tharshan@yahoo.co.sg',8572898929,950,str_to_date('20-NOV-09','%d-%b-%y'),'tshanmugaratnam','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (42,'Rebecca','Lim','reblim@msn.co.sg',8272438365,951,str_to_date('31-JUL-09','%d-%b-%y'),'rlim','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (43,'Rajiv','Chandrasekaran','rajiv_chan@yahoo.co.in',7431699965,952,str_to_date('14-APR-14','%d-%b-%y'),'rchan','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (44,'Tanya','Chua','tanyac@singers.sg',5435935345,953,str_to_date('14-APR-14','%d-%b-%y'),'tchua','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (45,'Janvi','Rajiv','janvi_jha@msn.co.sg',8324529953,952,str_to_date('14-APR-15','%d-%b-%y'),'jrajiv','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (46,'Tan Bee','Soo','tanbeesoo@yahoo.co.sg',8293092259,954,str_to_date('15-NOV-16','%d-%b-%y'),'tsoo','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (47,'Yun','Zhu','yunzho@gmail.com',9407380992,955,str_to_date('15-NOV-16','%d-%b-%y'),'yzhu','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (48,'Wajdi bin Abdul','Majeed','wajdiabdul@gmail.com',9380937709,956,str_to_date('25-JUN-10','%d-%b-%y'),'wabdul','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (49,'Anbara binti','Mubarak','anmubarak@yahoo.co.my',7885803452,957,str_to_date('27-AUG-10','%d-%b-%y'),'amubarak','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (50,'Sri binti ','Yaakob','sribinti@yahoo.co.my',8193579391,958,str_to_date('18-DEC-07','%d-%b-%y'),'sribinti','F');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (51,'Ahmad Bin Gh','Azali','ahmad_bingh@yahoo.co.my',7348292313,959,str_to_date('14-MAY-10','%d-%b-%y'),'abingh','M');
Insert into ONLINE_CUSTOMER (CUSTOMER_ID,CUSTOMER_FNAME,CUSTOMER_LNAME,CUSTOMER_EMAIL,CUSTOMER_PHONE,ADDRESS_ID,CUSTOMER_CREATION_DATE,CUSTOMER_USERNAME,CUSTOMER_GENDER) values (52,'Suchirithaa','Ekanayake','suchiritha@msn.com',6538525924,960,str_to_date('15-NOV-16','%d-%b-%y'),'sekanayake','F');
# INSERTING into ORDER_HEADER

Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10001,1,str_to_date('11-JUN-06','%d-%b-%y'),'Shipped','Credit Card',str_to_date('11-JUN-06','%d-%b-%y'),str_to_date('11-JUN-06','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10002,2,str_to_date('13-JUN-07','%d-%b-%y'),'Shipped','Cash',str_to_date('13-JUN-07','%d-%b-%y'),str_to_date('13-JUN-07','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10003,5,str_to_date('17-JUN-08','%d-%b-%y'),'Shipped','Cash',str_to_date('17-JUN-08','%d-%b-%y'),str_to_date('17-JUN-08','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10004,5,str_to_date('17-APR-10','%d-%b-%y'),'Shipped','Credit Card',str_to_date('17-APR-10','%d-%b-%y'),str_to_date('17-APR-10','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10005,5,str_to_date('18-JUL-11','%d-%b-%y'),'In process','Credit Card',str_to_date('18-JUL-11','%d-%b-%y'),null,50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10006,6,str_to_date('13-MAR-09','%d-%b-%y'),'Shipped','Net Banking',str_to_date('13-MAR-09','%d-%b-%y'),str_to_date('15-MAR-09','%d-%b-%y'),50003);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10007,3,str_to_date('25-MAR-09','%d-%b-%y'),'Shipped','Cash',str_to_date('25-MAR-09','%d-%b-%y'),str_to_date('25-MAR-09','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10008,7,str_to_date('16-APR-09','%d-%b-%y'),'Shipped','Credit Card',str_to_date('16-APR-09','%d-%b-%y'),str_to_date('18-APR-09','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10009,4,str_to_date('18-NOV-09','%d-%b-%y'),'Shipped','Credit Card',str_to_date('18-NOV-09','%d-%b-%y'),str_to_date('19-NOV-09','%d-%b-%y'),50003);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10010,6,str_to_date('03-FEB-10','%d-%b-%y'),'Shipped','Cash',str_to_date('05-FEB-10','%d-%b-%y'),str_to_date('05-FEB-10','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10011,1,str_to_date('19-JUL-10','%d-%b-%y'),'Shipped','Credit Card',str_to_date('19-JUL-10','%d-%b-%y'),str_to_date('21-JUL-10','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10012,2,str_to_date('24-JAN-11','%d-%b-%y'),'Shipped','Credit Card',str_to_date('24-JAN-11','%d-%b-%y'),str_to_date('25-JAN-11','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10013,8,str_to_date('16-AUG-11','%d-%b-%y'),'Cancelled',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10014,9,str_to_date('01-SEP-11','%d-%b-%y'),'Shipped','Credit Card',str_to_date('01-SEP-11','%d-%b-%y'),str_to_date('03-SEP-11','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10015,10,str_to_date('23-OCT-11','%d-%b-%y'),'Shipped','Credit Card',str_to_date('23-OCT-11','%d-%b-%y'),str_to_date('25-OCT-11','%d-%b-%y'),50003);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10016,8,str_to_date('28-OCT-11','%d-%b-%y'),'Shipped','Cash',str_to_date('29-OCT-11','%d-%b-%y'),str_to_date('29-OCT-11','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10017,6,str_to_date('01-NOV-11','%d-%b-%y'),'Shipped','Cash',str_to_date('03-NOV-11','%d-%b-%y'),str_to_date('03-NOV-11','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10018,11,str_to_date('15-NOV-11','%d-%b-%y'),'Shipped','Credit Card',str_to_date('15-NOV-11','%d-%b-%y'),str_to_date('17-NOV-11','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10019,12,str_to_date('03-DEC-11','%d-%b-%y'),'Shipped','Credit Card',str_to_date('03-DEC-11','%d-%b-%y'),str_to_date('05-DEC-11','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10020,18,str_to_date('01-MAR-12','%d-%b-%y'),'In process','Net Banking',str_to_date('01-MAR-12','%d-%b-%y'),null,50003);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10021,25,str_to_date('24-SEP-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('26-SEP-12','%d-%b-%y'),str_to_date('28-SEP-12','%d-%b-%y'),50006);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10022,23,str_to_date('12-FEB-13','%d-%b-%y'),'Shipped','Credit Card',str_to_date('12-FEB-13','%d-%b-%y'),str_to_date('14-FEB-13','%d-%b-%y'),50006);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10023,36,str_to_date('09-SEP-10','%d-%b-%y'),'Shipped','Credit Card',str_to_date('09-SEP-10','%d-%b-%y'),str_to_date('11-SEP-10','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10024,32,str_to_date('05-FEB-16','%d-%b-%y'),'Shipped','Net Banking',str_to_date('05-FEB-16','%d-%b-%y'),str_to_date('06-FEB-16','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10025,28,str_to_date('07-JAN-10','%d-%b-%y'),'Shipped','Credit Card',str_to_date('09-JAN-10','%d-%b-%y'),str_to_date('12-JAN-10','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10026,21,str_to_date('03-APR-16','%d-%b-%y'),'In process','Net Banking',str_to_date('05-APR-16','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10027,23,str_to_date('01-MAR-13','%d-%b-%y'),'Shipped','Credit Card',str_to_date('02-MAR-13','%d-%b-%y'),str_to_date('05-MAR-13','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10028,23,str_to_date('05-MAR-13','%d-%b-%y'),'In process','Credit Card',str_to_date('06-MAR-13','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10029,25,str_to_date('21-SEP-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('23-SEP-12','%d-%b-%y'),str_to_date('25-SEP-12','%d-%b-%y'),50003);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10030,52,str_to_date('12-DEC-16','%d-%b-%y'),'Shipped','Credit Card',str_to_date('14-DEC-16','%d-%b-%y'),str_to_date('15-DEC-16','%d-%b-%y'),50006);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10031,33,str_to_date('02-FEB-15','%d-%b-%y'),'Cancelled',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10032,7,str_to_date('27-JUN-17','%d-%b-%y'),'Shipped','Credit Card',str_to_date('27-JUN-07','%d-%b-%y'),str_to_date('29-JUN-07','%d-%b-%y'),50003);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10033,28,str_to_date('01-DEC-11','%d-%b-%y'),'Shipped','Credit Card',str_to_date('02-DEC-09','%d-%b-%y'),str_to_date('04-DEC-09','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10034,19,str_to_date('09-APR-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('11-APR-12','%d-%b-%y'),str_to_date('13-APR-12','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10035,24,str_to_date('07-APR-10','%d-%b-%y'),'Shipped','Net Banking',str_to_date('08-APR-10','%d-%b-%y'),str_to_date('10-APR-10','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10036,24,str_to_date('26-JAN-10','%d-%b-%y'),'Shipped','Cash',str_to_date('27-JAN-10','%d-%b-%y'),str_to_date('28-JAN-10','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10037,2,str_to_date('24-JUN-11','%d-%b-%y'),'Shipped','Cash',str_to_date('26-JUN-01','%d-%b-%y'),str_to_date('27-JUN-01','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10038,46,str_to_date('09-JAN-17','%d-%b-%y'),'Shipped','Net Banking',str_to_date('10-JAN-17','%d-%b-%y'),str_to_date('13-JAN-17','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10039,14,str_to_date('01-MAR-12','%d-%b-%y'),'Shipped','Net Banking',str_to_date('03-MAR-12','%d-%b-%y'),str_to_date('06-MAR-12','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10040,3,str_to_date('01-AUG-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('02-AUG-02','%d-%b-%y'),str_to_date('05-AUG-02','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10041,51,str_to_date('11-JUN-10','%d-%b-%y'),'Cancelled',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10042,26,str_to_date('24-MAR-10','%d-%b-%y'),'Shipped','Credit Card',str_to_date('26-MAR-10','%d-%b-%y'),str_to_date('29-MAR-10','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10043,17,str_to_date('13-APR-12','%d-%b-%y'),'Shipped','Net Banking',str_to_date('14-APR-12','%d-%b-%y'),str_to_date('16-APR-12','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10044,39,str_to_date('04-JUN-16','%d-%b-%y'),'In process','Net Banking',str_to_date('04-JUN-06','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10045,34,str_to_date('31-DEC-15','%d-%b-%y'),'In process','Credit Card',str_to_date('02-JAN-16','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10046,3,str_to_date('11-SEP-12','%d-%b-%y'),'Shipped','Net Banking',str_to_date('13-SEP-02','%d-%b-%y'),str_to_date('16-SEP-02','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10047,24,str_to_date('18-FEB-10','%d-%b-%y'),'Shipped','Net Banking',str_to_date('18-FEB-10','%d-%b-%y'),str_to_date('19-FEB-10','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10048,33,str_to_date('02-FEB-15','%d-%b-%y'),'Shipped','Cash',str_to_date('03-FEB-15','%d-%b-%y'),str_to_date('05-FEB-15','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10049,33,str_to_date('04-FEB-15','%d-%b-%y'),'In process','Credit Card',str_to_date('05-FEB-15','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10050,1,str_to_date('15-JUL-15','%d-%b-%y'),'In process','Net Banking',str_to_date('16-JUL-91','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10051,43,str_to_date('23-MAY-14','%d-%b-%y'),'Shipped','Credit Card',str_to_date('24-MAY-14','%d-%b-%y'),str_to_date('26-MAY-14','%d-%b-%y'),50006);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10052,17,str_to_date('04-MAY-12','%d-%b-%y'),'In process',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10053,40,str_to_date('26-DEC-16','%d-%b-%y'),'Shipped','Credit Card',str_to_date('26-DEC-16','%d-%b-%y'),str_to_date('29-DEC-16','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10054,19,str_to_date('25-JUN-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('26-JUN-12','%d-%b-%y'),str_to_date('29-JUN-12','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10055,25,str_to_date('19-SEP-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('21-SEP-12','%d-%b-%y'),str_to_date('23-SEP-12','%d-%b-%y'),50006);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10056,11,str_to_date('12-FEB-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('13-FEB-12','%d-%b-%y'),str_to_date('15-FEB-12','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10057,11,str_to_date('07-DEC-11','%d-%b-%y'),'Shipped','Cash',str_to_date('07-DEC-11','%d-%b-%y'),str_to_date('10-DEC-11','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10058,28,str_to_date('20-DEC-17','%d-%b-%y'),'In process',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10059,30,str_to_date('01-AUG-11','%d-%b-%y'),'Shipped','Net Banking',str_to_date('02-AUG-91','%d-%b-%y'),str_to_date('05-AUG-91','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10060,50,str_to_date('13-MAR-13','%d-%b-%y'),'Shipped','Credit Card',str_to_date('14-MAR-13','%d-%b-%y'),str_to_date('15-MAR-13','%d-%b-%y'),50005);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10061,37,str_to_date('03-AUG-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('03-AUG-12','%d-%b-%y'),str_to_date('05-AUG-12','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10062,34,str_to_date('04-DEC-15','%d-%b-%y'),'Cancelled',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10063,18,str_to_date('21-MAR-12','%d-%b-%y'),'Shipped','Credit Card',str_to_date('23-MAR-12','%d-%b-%y'),str_to_date('25-MAR-12','%d-%b-%y'),50001);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10064,35,str_to_date('21-MAR-14','%d-%b-%y'),'Shipped','Credit Card',str_to_date('21-MAR-14','%d-%b-%y'),str_to_date('22-MAR-14','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10065,17,str_to_date('08-MAR-12','%d-%b-%y'),'In process','Net Banking',str_to_date('08-MAR-12','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10066,41,str_to_date('21-DEC-17','%d-%b-%y'),'Cancelled',null,null,null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10067,6,str_to_date('17-MAY-16','%d-%b-%y'),'In process','Credit Card',str_to_date('18-MAY-06','%d-%b-%y'),null,null);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10068,51,str_to_date('11-JUL-10','%d-%b-%y'),'Shipped','Credit Card',str_to_date('12-JUL-10','%d-%b-%y'),str_to_date('14-JUL-10','%d-%b-%y'),50004);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10069,23,str_to_date('03-MAR-13','%d-%b-%y'),'Shipped','Net Banking',str_to_date('03-MAR-13','%d-%b-%y'),str_to_date('05-MAR-13','%d-%b-%y'),50002);
Insert into ORDER_HEADER (ORDER_ID,CUSTOMER_ID,ORDER_DATE,ORDER_STATUS,PAYMENT_MODE,PAYMENT_DATE,ORDER_SHIPMENT_DATE,SHIPPER_ID) values (10070,10,str_to_date('05-NOV-11','%d-%b-%y'),'Shipped','Net Banking',str_to_date('05-NOV-11','%d-%b-%y'),str_to_date('07-NOV-11','%d-%b-%y'),50001);
# INSERTING into ORDER_ITEMS

Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10001,205,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10001,201,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10001,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10001,244,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10002,238,4);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10002,235,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10002,241,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10002,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10002,206,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10002,208,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,202,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,203,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,215,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,224,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,225,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,231,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10003,234,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10004,217,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10004,222,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10004,223,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10004,220,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10004,219,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10005,204,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10005,206,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10005,207,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10005,209,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10005,210,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10005,218,10);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,211,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,242,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,238,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,232,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,228,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10006,236,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10007,213,20);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10007,214,25);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10007,218,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10007,216,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10007,236,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10007,240,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10008,226,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10008,227,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10008,235,10);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10008,240,8);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10009,229,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10009,201,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10009,221,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,244,4);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,211,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,202,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,209,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,225,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,231,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10010,233,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10011,211,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10011,212,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10011,222,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10012,201,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10012,204,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10012,207,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10012,210,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10012,218,10);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10012,219,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10023,208,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10026,211,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10027,219,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10023,206,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10044,206,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10014,216,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10014,214,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10014,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10014,207,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10014,201,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10014,202,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10015,228,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10015,240,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10015,242,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10015,244,4);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10015,243,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,210,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,209,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,206,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,227,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,234,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,233,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10016,228,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10017,220,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10017,236,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10017,240,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10017,216,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,223,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,231,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,244,6);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,218,15);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,235,15);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,226,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10018,225,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10019,207,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10019,224,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10019,227,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10019,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10060,237,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10019,202,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,201,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,243,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,218,20);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,219,4);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,206,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,204,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,203,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,221,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10020,233,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10060,238,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10032,248,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10032,247,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10028,246,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10029,246,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10064,246,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10021,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10021,227,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10021,231,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10021,235,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10022,202,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10022,241,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10023,207,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10024,216,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10024,201,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10025,206,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10025,219,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10026,221,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10027,217,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10028,207,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10029,204,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10030,233,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10032,219,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10032,214,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10032,233,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10033,232,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10033,236,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10034,227,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10034,232,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10035,242,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10035,222,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10035,243,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10036,235,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10036,236,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10036,216,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10037,238,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10037,245,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10038,215,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10038,240,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10038,243,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10039,211,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10040,215,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10040,234,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10042,209,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10042,228,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10044,208,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10046,212,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10047,203,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10047,215,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10048,207,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10049,245,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10049,202,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10050,223,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10050,233,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10050,204,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10054,205,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10054,231,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10057,204,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10058,229,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10058,209,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10059,221,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10045,237,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10063,232,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10060,233,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10061,215,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10064,209,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10067,206,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10067,234,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10068,205,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10068,242,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10069,204,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10069,236,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10069,238,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10043,218,10);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10043,240,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10045,245,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10045,241,10);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10045,244,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10051,241,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10051,226,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10052,227,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10053,223,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10055,220,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10055,233,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10056,219,2);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10063,239,5);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10063,231,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10063,213,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10065,235,3);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10065,220,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10070,238,1);
Insert into ORDER_ITEMS (ORDER_ID,PRODUCT_ID,PRODUCT_QUANTITY) values (10070,240,2);
# INSERTING into PRODUCT

Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99999,'Samsung Galaxy Tab 2 P3100',3000,19300,50,122,194,10,0.345);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99998,'Nikon Coolpix L810 Bridge',3000,14987,50,111,76,83,0.43);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99997,'Sony Xperia U (Black White)',3000,16499,50,54,112,12,0.11);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99994,'HP Deskjet 2050 All-in-One - J510a Printer',3001,3749,100,249,427,406,3.6);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99995,'LG MS-2049UW Solo Microwave',3001,4800,100,455,252,320,5.6);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99996,'Nokia Asha 200 (Graphite)',3001,4070,100,61,115,14,0.105);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99991,'Dell Targus Synergy 2.0 Backpack',3002,999,250,450,250,50,0.5);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99992,'Tom Clancy''s Ghost Recon: Future Soldier (PC Game)',3002,999,250,150,200,10,0.1);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99993,'Nokia 1280 (Black)',3002,999,250,45,107,15,0.082);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (201,'Sky LED 102 CM TV',2050,35000,30,905,750,700,15);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (202,'Sams 192 L4 Single-door Refrigerator',2050,28000,15,1802,750,750,25);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (203,'Jocky Speaker Music System HT32',2050,8900,19,908,300,300,5);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (204,'Cricket Set for Boys',2051,4500,10,890,300,200,18);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (205,'Infant Sleepwear Blue',2052,250,50,596,300,100,0.25);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (206,'Barbie Fab Gown Doll',2051,1000,20,305,150,75,0.15);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (207,'Remote Control Car',2051,2900,29,200,150,50,0.225);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (208,'Doll House',2051,3000,12,600,455,375,0.9);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (209,'Blue Jeans 34',2052,800,100,450,310,52,1.1);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (210,'Blossoms Lehenga Choli set',2052,3000,100,600,315,54,0.25);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (211,'OnePlus 6 Smart Phone',2055,32500,25,100,65,15,0.55);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (212,'Samsung Galaxy On6',2055,14000,20,120,70,18,0.65);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (213,'Alchemist',2054,150,50,200,100,20,0.235);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (214,'Harry Potter',2054,250,50,210,100,50,0.345);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (215,'Logtech M244 Optical Mouse',2053,450,10,125,85,45,0.105);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (216,'External Hard Disk 500 GB',2053,3500,10,275,285,85,0.525);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (217,'Titan Karishma Watch',2057,3497,35,220,55,24,0.103);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (218,'Shell Fingertip Ball Pen',2056,25,150,170,12,170,0.05);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (219,'Ruf-n-Tuf Black PU Leather Belt',2052,350,50,700,45,4,0.155);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (220,'Hello Kitti Lunch Bag',2059,199,15,455,300,225,0.5);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (221,'Cybershot DWC-W325 Camera',2050,5300,5,100,55,40,0.05);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (222,'KitchAsst Siphon Coffee Maker 500 ml',2060,1790,10,150,100,200,1.2);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (223,'Sams 21L Microwave Oven',2060,6880,5,500,400,300,8);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (224,'Phils HL 7430 Mixer Grinder 750W',2060,2265,3,375,400,355,3);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (225,'Solmo Non-stick Sandwich Maker 750 W',2060,1625,10,150,175,70,0.75);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (226,'Solmo Hand Blender Fibre',2060,1415,12,220,100,220,0.56);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (227,'Phils Wah Collection Juicer JM12',2060,2029,2,400,450,425,4);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (228,'Adidas Analog Watch',2057,2295,10,225,60,28,0.115);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (229,'Disney Analog Watch',2057,1600,10,225,60,28,0.115);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (230,'Esprit Analog Watch',2057,3495,5,225,60,28,0.115);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (231,'HP ODC Laptop Bag 15.5',2059,3390,10,550,400,210,0.255);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (232,'Women Hand Bag',2059,1600,15,250,220,170,0.175);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (233,'HP ODC School Bag 2.5''',2059,799,35,600,450,275,0.355);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (234,'FLUFF Tote Travel Bag 35LTR',2059,3290,8,900,800,600,4);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (236,'Solo Exam SB-01 Writing Pad',2056,350,30,400,300,5,0.55);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (238,'Kasyo DJ-2100 Desktop Calculator',2056,338,10,150,120,120,0.55);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (239,'TRANS 2D A4 Size Box File',2056,120,6,350,300,100,0.315);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (240,'4M Post It Pad 3.5',2056,35,8,80,80,150,0.12);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (242,'GreenWud CT-NO-PR Coffee Table',2058,3500,6,1250,550,700,50);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (243,'Supreme Fusion Cupboard 02TB',2058,3000,3,1200,350,900,60);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (244,'Foldable Premium Chair',2058,4000,6,75,70,90,20);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (245,'GreenWud Nova Pedestal Unit',2058,2500,5,400,400,600,25);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (235,'Cindy HMPOC Pencil Box (Multicolor)',2056,80,10,250,50,15,0.45);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (237,'Zamark Color Pencil Art Set',2056,100,10,120,90,20,0.35);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (241,'PK Copier A4 75 GSM White Paper Ream',2056,285,2,297,210,null,null);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (246,'Exam Warriors',2054,100,50,200,160,15,0.1);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (247,'Small Is Beautiful',2054,140,40,180,100,15,0.1);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (248,'To Kill a Mocking Bird',2054,210,35,190,150,20,0.15);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (249,'All-in-one Board Game',2051,450,20,750,320,90,0.5);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (250,'Huwi Wi-Fi Receiver 500Mbps',2053,287,30,100,95,30,0.1);
Insert into PRODUCT (PRODUCT_ID,PRODUCT_DESC,PRODUCT_CLASS_CODE,PRODUCT_PRICE,PRODUCT_QUANTITY_AVAIL,LEN,WIDTH,HEIGHT,WEIGHT) values (99990,'Quanta 4 Port USB Hub',3000,500,50,180,125,30,0.05);
# INSERTING into PRODUCT_CLASS

Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (3001,'Promotion-Medium Value');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (3002,'Promotion-Low Value');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2050,'Electronics');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2051,'Toys');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2052,'Clothes');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2053,'Computer');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2054,'Books');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2055,'Mobiles');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2056,'Stationery');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2057,'Watches');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2058,'Furnitures');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2059,'Bags');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (2060,'Kitchen Items');
Insert into PRODUCT_CLASS (PRODUCT_CLASS_CODE,PRODUCT_CLASS_DESC) values (3000,'Promotion-High Value');
# INSERTING into SHIPPER

Insert into SHIPPER (SHIPPER_ID,SHIPPER_NAME,SHIPPER_PHONE,SHIPPER_ADDRESS) values (50001,'DHL',9456756761,1000);
Insert into SHIPPER (SHIPPER_ID,SHIPPER_NAME,SHIPPER_PHONE,SHIPPER_ADDRESS) values (50002,'Blue Dart',9456756777,1001);
Insert into SHIPPER (SHIPPER_ID,SHIPPER_NAME,SHIPPER_PHONE,SHIPPER_ADDRESS) values (50003,'DTDC',9845967834,1002);
Insert into SHIPPER (SHIPPER_ID,SHIPPER_NAME,SHIPPER_PHONE,SHIPPER_ADDRESS) values (50004,'Flipkart',9785985621,1003);
Insert into SHIPPER (SHIPPER_ID,SHIPPER_NAME,SHIPPER_PHONE,SHIPPER_ADDRESS) values (50005,'Professional',9343978654,1004);
Insert into SHIPPER (SHIPPER_ID,SHIPPER_NAME,SHIPPER_PHONE,SHIPPER_ADDRESS) values (50006,'FedEx',8925349243,1005);
#-------------------------------------------------------
#--  DDL for Index SYS_C006087
#-------------------------------------------------------

  CREATE UNIQUE INDEX addr_id_indx ON ADDRESS (ADDRESS_ID) 
  ;
#-------------------------------------------------------
#--  DDL for Index CARTON_PK
#-------------------------------------------------------

  CREATE UNIQUE INDEX CARTON_PK ON CARTON (CARTON_ID) 
  ;
#-------------------------------------------------------
#--  DDL for Index SYS_C006084
#-------------------------------------------------------

  CREATE UNIQUE INDEX online_custid_indx ON ONLINE_CUSTOMER (CUSTOMER_ID) 
  ;
#-------------------------------------------------------
#--  DDL for Index SYS_C006085
#-------------------------------------------------------

  CREATE UNIQUE INDEX online_email_indx ON ONLINE_CUSTOMER (CUSTOMER_EMAIL) 
  ;
#-------------------------------------------------------
#--  DDL for Index PK_ORD_H
#-------------------------------------------------------

  CREATE UNIQUE INDEX PK_ORD_H ON ORDER_HEADER (ORDER_ID) 
  ;
#-------------------------------------------------------
#--  DDL for Index PK_ORD_PROD
#-------------------------------------------------------

  CREATE UNIQUE INDEX PK_ORD_PROD ON ORDER_ITEMS (ORDER_ID, PRODUCT_ID) 
  ;
#-------------------------------------------------------
#--  DDL for Index PK_PROD
#-------------------------------------------------------

  CREATE UNIQUE INDEX PK_PROD ON PRODUCT (PRODUCT_ID) 
  ;
#-------------------------------------------------------
#--  DDL for Index PK_PROD_CLASS
#-------------------------------------------------------

  CREATE UNIQUE INDEX PK_PROD_CLASS ON PRODUCT_CLASS (PRODUCT_CLASS_CODE) 
  ;
#-------------------------------------------------------
#--  DDL for Index PK_SHIP_ID
#-------------------------------------------------------

  CREATE UNIQUE INDEX PK_SHIP_ID ON SHIPPER (SHIPPER_ID) 
  ;
#-------------------------------------------------------
#--  Constraints for Table ADDRESS
#-------------------------------------------------------

  ALTER TABLE ADDRESS MODIFY ADDRESS_LINE1 VARCHAR(50) NOT NULL;
  ALTER TABLE ADDRESS ADD PRIMARY KEY (ADDRESS_ID);
  ALTER TABLE ADDRESS MODIFY CITY VARCHAR(30) NOT NULL;
#-------------------------------------------------------
#--  Constraints for Table CARTON
#-------------------------------------------------------

  ALTER TABLE CARTON ADD CONSTRAINT CARTON_PK PRIMARY KEY (CARTON_ID);
#-------------------------------------------------------
#--  Constraints for Table ONLINE_CUSTOMER
#-------------------------------------------------------

  ALTER TABLE ONLINE_CUSTOMER MODIFY CUSTOMER_GENDER CHAR(1) NOT NULL ;
  ALTER TABLE ONLINE_CUSTOMER MODIFY CUSTOMER_FNAME VARCHAR(20) NOT NULL ;
  ALTER TABLE ONLINE_CUSTOMER ADD PRIMARY KEY (CUSTOMER_ID);
  ALTER TABLE ONLINE_CUSTOMER ADD UNIQUE (CUSTOMER_EMAIL);
#-------------------------------------------------------
#--  Constraints for Table ORDER_HEADER
#-------------------------------------------------------

  ALTER TABLE ORDER_HEADER ADD CONSTRAINT PK_ORD_H PRIMARY KEY (ORDER_ID);
#-------------------------------------------------------
#--  Constraints for Table ORDER_ITEMS
#-------------------------------------------------------

  ALTER TABLE ORDER_ITEMS ADD CONSTRAINT PK_ORD_PROD PRIMARY KEY (ORDER_ID, PRODUCT_ID);
#-------------------------------------------------------
#--  Constraints for Table PRODUCT
#-------------------------------------------------------

  ALTER TABLE PRODUCT ADD CONSTRAINT PK_PROD PRIMARY KEY (PRODUCT_ID);
#-------------------------------------------------------
#--  Constraints for Table PRODUCT_CLASS
#-------------------------------------------------------

  ALTER TABLE PRODUCT_CLASS ADD CONSTRAINT PK_PROD_CLASS PRIMARY KEY (PRODUCT_CLASS_CODE);
  ALTER TABLE PRODUCT_CLASS MODIFY PRODUCT_CLASS_DESC VARCHAR(40) NOT NULL ;
#-------------------------------------------------------
#--  Constraints for Table SHIPPER
#-------------------------------------------------------

  ALTER TABLE SHIPPER ADD CONSTRAINT PK_SHIP_ID PRIMARY KEY (SHIPPER_ID);
  ALTER TABLE SHIPPER MODIFY SHIPPER_NAME VARCHAR(40) NOT NULL;
  ALTER TABLE SHIPPER MODIFY SHIPPER_PHONE DECIMAL (10,0) NOT NULL ; 

-- 1. Display the product details as per the following criteria and sort them in descending order of category:
   #a.  If the category is 2050, increase the price by 2000
   #b.  If the category is 2051, increase the price by 500
   #c.  If the category is 2052, increase the price by 600

select product_id,product_desc,product_class_code,product_quantity_avail,len,width,height,weight,product_price,
case
when product_class_code=2050 then product_price+2000
when product_class_code=2051 then product_price+500
when product_class_code=2052 then product_price+600
else product_price
end as increased_price
from product;

-- 2. List the product description, class description and price of all products which are shipped. 

select * from product;
select * from product_class;
select * from order_header;
select * from order_items;
select * from online_customer;


# Joining 4 tables product,product_class,order_items,order_header

select product_id,product_desc,a.product_class_code,product_price,product_class_desc,o.order_id,order_status
from product a join product_class b
using(product_class_code)
join order_items o
using(product_id)
join order_header oh
using(order_id);

# Using CTE selecting only for shipped order_status.

select product_desc,product_class_desc,product_price,order_status from
(select product_id,product_desc,a.product_class_code,product_price,product_class_desc,o.order_id,order_status
from product a join product_class b
using(product_class_code)
join order_items o
using(product_id)
join order_header oh
using(order_id))t
where order_status='Shipped'
group by product_id;

-- 3. Show inventory status of products as below as per their available quantity:
#a. For Electronics and Computer categories, if available quantity is < 10, show 'Low stock', 11 < qty < 30, show 'In stock', > 31, show 'Enough stock'
#b. For Stationery and Clothes categories, if qty < 20, show 'Low stock', 21 < qty < 80, show 'In stock', > 81, show 'Enough stock'
#c. Rest of the categories, if qty < 15 – 'Low Stock', 16 < qty < 50 – 'In Stock', > 51 – 'Enough stock'
#For all categories, if available quantity is 0, show 'Out of stock'.


select * from product;
select * from product_class;

# Joining tables product,product_class

select product_id,product_desc,a.product_class_code,product_price,product_quantity_avail,product_class_desc
from product a join product_class b
using(product_class_code);

# Using this for making inventory on attribute product_class_desc

select product_id,product_desc,a.product_class_code,product_price,product_class_desc,product_quantity_avail,
case
when product_class_desc in ('Electronics','Computer') and (product_quantity_avail<10) then 'Low Stock'
when product_class_desc in ('Electronics','Computer') and (product_quantity_avail between 10 and 30) then 'In Stock'
when product_class_desc in ('Electronics','Computer') and (product_quantity_avail>30) then 'Enough Stock'
when product_class_desc in ('Stationery','Clothes') and (product_quantity_avail<20) then 'Low Stock'
when product_class_desc in ('Stationery','Clothes') and (product_quantity_avail between 20 and 80) then 'In Stock'
when product_class_desc in ('Stationery','Clothes') and (product_quantity_avail>80) then 'Enough Stock'
when product_class_desc not in ('Electronics','Computer','Stationery','Clothes') and (product_quantity_avail<15) then 'Low Stock'
when product_class_desc not in ('Electronics','Computer','Stationery','Clothes') and (product_quantity_avail between 15 and 50) then 'In Stock'
when product_class_desc not in ('Electronics','Computer','Stationery','Clothes') and (product_quantity_avail>50) then 'Enough Stock'
when product_quantity_avail<0 then 'Out of Stock'
end as Inventory_Status
from product a join product_class b
using(product_class_code);

-- Q4. List customers from outside Karnataka who haven’t bought any toys or books.

select * from product;
select * from product_class;
select * from address;
select * from online_customer;
select * from order_items;
select * from order_header;
select * from address;

# Joining tables product,product_class,order_items,order_header,online_customer,address.

select customer_fname,customer_lname,product_id,product_desc,a.product_class_code,product_price,product_class_desc,o.order_id,
order_status,oh.customer_id,oc.address_id,state
from product a join product_class b
using(product_class_code)
join order_items o
using(product_id)
join order_header oh
using(order_id)
join online_customer oc
using(customer_id)
join address ad
using(address_id);

# Using CTE selecting customers who did not order toys or books from outside Karnataka.

select * from
(select customer_fname,customer_lname,product_id,product_desc,a.product_class_code,product_price,product_class_desc,o.order_id,
order_status,oh.customer_id,oc.address_id,state
from product a join product_class b
using(product_class_code)
join order_items o
using(product_id)
join order_header oh
using(order_id)
join online_customer oc
using(customer_id)
join address ad
using(address_id))t
where product_class_desc not in('Toys','Books') and state not in ('Karnataka') or state is NULL
group by customer_id;