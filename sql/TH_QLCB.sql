create database QLCB;
go 
use QLCB;

create table CHUYENBAY (
MACB char(5) PRIMARY KEY,
NOIXP varchar(50),
NOIDEN varchar(50),
MAMB char(5),
MAPC char(5),
KCBAY int,
THOIGIANXP smalldatetime,
THOIGIANDEN smalldatetime,
)

create table MAYBAY (
MAMB char(5),
TENMB varchar(50),
KCBAYTOIDA int,
)

create table PHICONG (
MAPC char(5),
TENPC varchar(50),
MUCLUONG money,
)

alter table CHUYENBAY add 
constraint CB_MAMB foreign key (MAMB) references MAYBAY(MAMB),
constraint CB_MAPC foreign key (MAPC) references PHICONG(MAPC)

alter table CHUYENBAY add
constraint CB_NOI check (NOIXP <> NOIDEN)
go

create trigger trg22
on MAYBAY
for update
as
	declare @KCBAYTOIDA int, @KCBAY int
	select @KCBAYTOIDA = KCBAYTOIDA, @KCBAY = KCBAY
	from INSERTED as I, CHUYENBAY as CB
	where I.MAMB = CB.MAMB
	if (@KCBAYTOIDA > @KCBAY)
	begin
		print 'Khong hop le'
		rollback transaction
	end
	else
	begin
		print 'Thanh cong'
	end

select MB.TENMB from CHUYENBAY as CB, MAYBAY as MB
where CB.MAMB = MB.MAMB 
and CB.NOIXP = 'TP HCM' and CB.NOIDEN = 'HANOI'

select top 1 with ties MB.MAMB, MB.TENMB
from MAYBAY as MB
group by MB.MAMB, MB.TENMB
order by MB.KCBAYTOIDA desc

select top 1 with ties PC.MAPC, PC.TENPC
from PHICONG as PC, CHUYENBAY as CB
where PC.MAPC = CB.MAPC 
and CB.NOIXP = 'TPHCM'
group by PC.MAPC, PC.TENPC
order by count(CB.MACB) desc