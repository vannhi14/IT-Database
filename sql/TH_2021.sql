create database TH2021;
go
use TH2021;

create table PHONGBAN
(
	MAPHG varchar(2) PRIMARY KEY,
	TENPHG varchar(50),
	TRPHG varchar(3),
	NGNC smalldatetime
)

create table NHANVIEN 
(
	MANV varchar(3) PRIMARY KEY,
	HOTEN varchar(40),
	NGSINH smalldatetime,
	PHAI varchar(3),
	DIACHI varchar(50),
	MAPHG varchar(2),
	LUONG money
)

create table DEAN 
(
	MADA varchar(5) PRIMARY KEY,
	TENDA varchar(50),
	DDIEM_DA varchar(50),
	MAPHG varchar(2),
	NGBD_DK smalldatetime,
	NGKT_DK smalldatetime
)

create table PHANCONG
(
	MANV varchar(3),
	MADA varchar(5),
	THOIGIAN int,
	constraint MANV_MADA PRIMARY KEY (MANV, MADA)
)

alter table PHONGBAN add
constraint PB_TRPHG foreign key (TRPHG) references NHANVIEN(MANV)

alter table NHANVIEN add
constraint NV_MAPHG foreign key (MAPHG) references PHONGBAN(MAPHG)

alter table DEAN add
constraint DA_MAPHG foreign key (MAPHG) references PHONGBAN(MAPHG)

alter table PHANCONG add
constraint PC_MANV foreign key (MANV) references NHANVIEN(MANV),
constraint PC_MADA foreign key (MADA) references DEAN(MADA)

go

--2.1
create trigger trgnv
on NHANVIEN
for insert, update
as
	declare @MAPHG varchar(2), @LUONG money
	select @MAPHG = MAPHG
	from inserted
	if (@MAPHG = 'NC')
	begin
		select @LUONG = LUONG
		from inserted
		if (@LUONG < 20000000)
		begin
			print 'Loi'
			rollback transaction
		end
		else
		begin
			print 'Thanh cong'
		end
	end

--2.1
alter table NHANVIEN add
constraint NV_Luong check (MAPHG = 'NC' and LUONG > 2000000)
go
--2.2
create trigger trgng
on DEAN
for insert, update
as 
	declare @NGSINH smalldatetime, @NGBD_DK smalldatetime
	select @NGBD_DK = NGBD_DK, @NGSINH = NGSINH
	from INSERTED, NHANVIEN, PHANCONG
	where INSERTED.MADA = PHANCONG.MADA and PHANCONG.MANV = NHANVIEN.MANV
	if(@NGBD_DK < @NGSINH)
	begin 
		print 'Loi'
		rollback transaction
	end
	else
	begin
		print 'Thanh cong'
	end

--3a
select PHONGBAN.TENPHG from PHONGBAN, NHANVIEN
where NHANVIEN.MAPHG = PHONGBAN.MAPHG
group by PHONGBAN.TENPHG
having avg(NHANVIEN.LUONG) > 24000000
order by PHONGBAN.TENPHG desc

--3b
select NHANVIEN.HOTEN 
from NHANVIEN, PHONGBAN, DEAN
where NHANVIEN.MAPHG = PHONGBAN.MAPHG
and PHONGBAN.MAPHG = DEAN.MAPHG
and PHONGBAN.TENPHG = 'Nghien Cuu'
and DEAN.DDIEM_DA = 'Ha Noi'

--3c
select NHANVIEN.HOTEN, count(PHANCONG.MADA) as SODEANTGIA
from NHANVIEN, PHANCONG
where NHANVIEN.MANV = PHANCONG.MANV

--3d
select NHANVIEN.HOTEN 
from NHANVIEN, PHANCONG, DEAN, PHONGBAN
where NHANVIEN.MANV = PHANCONG.MANV and PHANCONG.MADA = DEAN.MADA
and DEAN.MAPHG = PHONGBAN.MAPHG and PHONGBAN.TENPHG = 'Nghien Cuu'
except
select NHANVIEN.HOTEN 
from NHANVIEN, PHANCONG, DEAN, PHONGBAN
where NHANVIEN.MANV = PHANCONG.MANV and PHANCONG.MADA = DEAN.MADA
and DEAN.MAPHG = PHONGBAN.MAPHG and PHONGBAN.TENPHG <> 'Nghien Cuu'

--3e
select NHANVIEN.HOTEN from NHANVIEN
where not exists (
	select * from PHONGBAN, DEAN
	where PHONGBAN.MAPHG = DEAN.MAPHG
	and PHONGBAN.TENPHG = 'Dieu Hanh'
	and not exists (
		select * from PHANCONG
		where PHANCONG.MANV = NHANVIEN.MANV
		and PHANCONG.MADA = DEAN.MADA
	)
)

--3f
select top 1 with ties PHONGBAN.TENPHG, NHANVIEN.HOTEN
from PHONGBAN, NHANVIEN
where PHONGBAN.TRPHG = NHANVIEN.MANV
group by PHONGBAN.TENPHG, NHANVIEN.HOTEN
order by count(NHANVIEN.MANV) desc