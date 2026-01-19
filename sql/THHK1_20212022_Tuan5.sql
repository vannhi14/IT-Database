/*
create database THHKT2;
go
use THHKT2;
---

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

--
SET DATEFORMAT DMY 

INSERT INTO PHONGBAN VALUES ('QL','Quan ly',NULL, '22/05/2018')
INSERT INTO PHONGBAN VALUES ('DH','Dieu hanh',NULL, '10/11/2020')
INSERT INTO PHONGBAN VALUES ('NC','Nghien cuu',NULL, '15/03/2020')

INSERT INTO NHANVIEN VALUES ('001','Vuong Ngoc Quyen','22/10/1977', 'Nu', '450 Trung Vuong', 'QL', 30000000)
INSERT INTO NHANVIEN VALUES ('002','Nguyen Thanh Tu','09/01/1975', 'Nam', '731 Tran Hung Dao', 'NC', 25000000)
INSERT INTO NHANVIEN VALUES ('003','Le Thi Nhan','18/12/1980', 'Nu', '291 Ho Van Que', 'DH', 25000000)
INSERT INTO NHANVIEN VALUES ('004','Dinh Ba Tien','09/01/1988', 'Nam', '638 Nguyen Van Cu', 'NC', 22000000)
INSERT INTO NHANVIEN VALUES ('005','Nguyen Thuy Vy','10/07/1975', 'Nam', '332 Nguyen Thai Hoc', 'DH', 23000000)

UPDATE PHONGBAN
SET TRPHG='001'
WHERE MAPHG='QL'

UPDATE PHONGBAN
SET TRPHG='003'
WHERE MAPHG='DH'

UPDATE PHONGBAN
SET TRPHG='002'
WHERE MAPHG='NC'

INSERT INTO DEAN VALUES ('TH001', 'Tin hoc hoa 1','HANOI', 'NC', '01/02/2018', '01/02/2019')
INSERT INTO DEAN VALUES ('TH002', 'Tin hoc hoa 2','TPHCM', 'NC', '04/06/2018', '01/02/2019')
INSERT INTO DEAN VALUES ('DT001', 'Dao tao 1','NHATRANG', 'DH', '01/02/2017', '01/02/2021')
INSERT INTO DEAN VALUES ('DT002', 'Dao tao 2','HANOI', 'DH', '01/02/2017', '01/02/2021')

INSERT INTO PHANCONG VALUES ('001', 'TH001',30)
INSERT INTO PHANCONG VALUES ('001', 'TH002',12)
INSERT INTO PHANCONG VALUES ('002', 'TH001',10)
INSERT INTO PHANCONG VALUES ('002', 'TH002',10)
INSERT INTO PHANCONG VALUES ('002', 'DT001',10)
INSERT INTO PHANCONG VALUES ('002', 'DT002',10)
INSERT INTO PHANCONG VALUES ('003', 'TH001',37)
INSERT INTO PHANCONG VALUES ('004', 'DT001',22)
INSERT INTO PHANCONG VALUES ('004', 'DT002',10)
--
--3a
select PB.TENPHG from PHONGBAN as PB, NHANVIEN as NV
where	PB.MAPHG = NV.MAPHG 
group by TENPHG
having AVG(LUONG) > 24000000
order by TENPHG desc
--3b
select NV.HOTEN from NHANVIEN as NV, PHONGBAN as PB, DEAN as DA, PHANCONG as PC
where NV.MANV = PC.MANV and PC.MADA = DA.MADA and DA.MAPHG = PB.MAPHG 
and PB.TENPHG = 'Nghien Cuu' and DA.DDIEM_DA = 'HANOI'
--3c
select HOTEN, count(MADA) as SLDA
from NHANVIEN as NV, PHANCONG as PC
where NV.MANV = PC.MANV group by HOTEN 
--3d
select NV.HOTEN from NHANVIEN as NV
where NV.MANV in (
    select PC.MANV from PHANCONG as PC, DEAN as DA, PHONGBAN as PB
    where PC.MADA = DA.MADA and PB.MAPHG = DA.MAPHG AND PB.TENPHG = 'Nghien Cuu'
    except
    select PC.MANV from PHANCONG as PC, DEAN as DA, PHONGBAN as PB
    where PC.MADA = DA.MADA and PB.MAPHG = DA.MAPHG and PB.TENPHG <> 'Nghien Cuu'
)
--3e
select HOTEN from NHANVIEN as NV
where not exists (
	select * from DEAN as DA, PHONGBAN as PB 
	where DA.MAPHG = PB.MAPHG 
	and PB.TENPHG = 'Dieu Hanh'
	and not exists (
		select * from PHANCONG as PC
		where PC.MADA = DA.MADA
		and PC.MANV = NV.MANV 
		)
	)
--3f
select PB.TENPHG, NV.HOTEN from PHONGBAN as PB, NHANVIEN as NV
where NV.MANV = PB.TRPHG and PB.MAPHG in (
	select top 1 with ties MAPHG
	from NHANVIEN
	group by MAPHG
	order by count(MANV) desc
)
*/
--Cau 2
--a
create trigger trga
on NHANVIEN 
for insert, update
as
		declare @MAPHG varchar(2), @LUONG money
		select @MAPHG = MAPHG
		from INSERTED
		if(@MAPHG = 'NC')
		begin 
			select @LUONG = LUONG
			from INSERTED
			if (@LUONG <= 2000000)
			begin
				print 'Loi: Luong cua nhan vien phong NC phai lon hon 2000000'
				rollback transaction
			end
			else
			begin
				print 'Cap nhat luong thanh cong!'
			end
		end
--b
create trigger trgb
on DEAN
for insert, update
as
	declare @NGBD_DK smalldatetime, @NGSINH smalldatetime
	select @NGBD_DK = NGBD_DK, @NGSINH = NGSINH
	from INSERTED as I, NHANVIEN as NV, PHANCONG as PC
	where I.MADA = PC.MADA and NV.MANV = PC.MANV
	if (@NGBD_DK < @NGSINH)
	begin
		print 'Loi: Ngay bat dau de an khong hop le'
		rollback transaction
	end
	else 
	begin
	print 'Dang ky ngay bat dau de an thanh cong!'
	end


