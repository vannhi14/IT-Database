create database THCK;
go
use THCK;

create table DOIBONG (
MADOI varchar(2) PRIMARY KEY,
TENDOI varchar(100),
NAMTHANHLAP int,
THANHPHO varchar(50)
)

create table CAUTHU (
MACAUTHU varchar(2) PRIMARY KEY,
TENCAUTHU varchar(50),
NGAYSINH smalldatetime,
PHAI bit,
NOISINH varchar(50)
)

create table CT_DB (
MADOI varchar(2),
MACAUTHU varchar(2),
NGAYVAOCLB smalldatetime,
constraint MADOI_CAUTHU PRIMARY KEY (MADOI, MACAUTHU)
)

create table THIDAU (
MADOI varchar(2),
NGAYTHIDAU smalldatetime,
HIEUSO int,
KETQUA bit, 
constraint MADOI_NGTHIDAU PRIMARY KEY (MADOI, NGAYTHIDAU)
)

alter table CT_DB add
constraint CTDB_MADOI foreign key (MADOI) references DOIBONG(MADOI),
constraint CTDB_MACAUTHU foreign key (MACAUTHU) references CAUTHU(MACAUTHU)

alter table THIDAU add
constraint TD_MADOI foreign key (MADOI) references DOIBONG(MADOI)
go

--2a
create trigger trgkq
on THIDAU
for update
as
	declare @KETQUA bit
	select @KETQUA = KETQUA 
	from INSERTED
	if(@KETQUA = 1)
	begin 
		print N'Thắng'
	end
	if(@KETQUA = 0)
	begin
		print 'Thua'
	end
go

--2b
create trigger trgng
on CT_DB
for insert, update 
as 
	declare @NGAYVAOCLB smalldatetime, @NAMTHANHLAP smalldatetime
	select @NGAYVAOCLB = YEAR(NGAYVAOCLB), @NAMTHANHLAP = NAMTHANHLAP
	from INSERTED, DOIBONG
	where INSERTED.MADOI = DOIBONG.MADOI
	if (@NGAYVAOCLB < @NAMTHANHLAP)
	begin
		print 'Nam gia nhap CLB khong duoc nho hon nam thanh lap doi bong'
		rollback transaction
	end
	else 
	begin
		print 'Thanh cong'
	end

--3a
select TENDOI, NAMTHANHLAP from DOIBONG 
where NAMTHANHLAP > 2000 and THANHPHO = N'Hà Nội'

--3b
select CT.TENCAUTHU 
from CAUTHU as CT, DOIBONG as DB, CT_DB, THIDAU as TD
where CT.MACAUTHU = CT_DB.MACAUTHU and CT_DB.MADOI = DB.MADOI and TD.MADOI = DB.MADOI
and DB.TENDOI = N'Quân khu 7' and TD.KETQUA = 1
group by CT.TENCAUTHU
order by CT.TENCAUTHU desc

--3c
select DB.TENDOI, count(TD.NGAYTHIDAU) as SOTRANTHAMGIA
from DOIBONG as DB, THIDAU as TD
where DB.MADOI = TD.MADOI
group by DB.TENDOI

--3d
select CT.TENCAUTHU
from CAUTHU as CT, CT_DB, DOIBONG as DB
where CT.MACAUTHU = CT_DB.MACAUTHU and CT_DB.MADOI = DB.MADOI
and DB.TENDOI = N'SHB Đà Nẵng'
except 
select CT.TENCAUTHU
from CAUTHU as CT, CT_DB, DOIBONG as DB
where CT.MACAUTHU = CT_DB.MACAUTHU and CT_DB.MADOI = DB.MADOI
and DB.TENDOI = N'Sông Lam Nghệ An'

--3e
select top 1 with ties DB.MADOI, DB.TENDOI, count(TD.NGAYTHIDAU) as SOLANTHANG
from DOIBONG as DB, THIDAU as TD
where DB.MADOI = TD.MADOI and TD.KETQUA = 1
group by DB.MADOI, DB.TENDOI
order by count(TD.NGAYTHIDAU) desc

--3f
select CT.MACAUTHU, CT.TENCAUTHU from CAUTHU as CT
where not exists (
	select * from DOIBONG as DB
	where DB.THANHPHO = N'Thành phố Hồ Chí Minh'
	and not exists(
		select * from CT_DB
		where CT_DB.MACAUTHU = CT.MACAUTHU
		and CT_DB.MADOI = DB.MADOI))

