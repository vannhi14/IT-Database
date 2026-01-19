create database TTHD2;
go
use TTHD2;
create table NHANVIEN
(
	MaNV char(5) PRIMARY KEY,
	HoTen varchar(5),
	NgayVL smalldatetime,
	HSLuong numeric(4,2),
	MaPhong char(5)
)
create table PHONGBAN
(
	MaPhong char(5) PRIMARY KEY,
	TenPhong varchar(25),
	TruongPhong char(5)
)
create table XE
(
	MaXe char(5) PRIMARY KEY,
	LoaiXe varchar(20),
	SoChoNgoi int,
	NamSX int
)
create table PHANCONG
(
	MaPC char(5) PRIMARY KEY,
	MaNV char(5),
	MaXe char(5),
	NgayDi smalldatetime,
	NgayVe smalldatetime,
	NoiDen varchar(25)
)
alter table PHONGBAN add
constraint PB_TRGPHG foreign key (TruongPhong) references NHANVIEN(MaNV)

alter table PHANCONG add
constraint PC_MaNV foreign key (MaNV) references NHANVIEN(MaNV),
constraint PC_MaXe foreign key (MaXe) references XE(MaXe)
go

--2.1
create trigger trg21
on XE
for insert, update 
as
	declare @LoaiXe varchar(20), @NamSX int
	select @LoaiXe = LoaiXe, @NamSX = NamSX
	from INSERTED 
	where LoaiXe = 'Toyota'
		if(@NamSX < 2006)
			begin 
				print 'Loi: Nam san xuat khong hop le'
				rollback transaction
			end
		else
			begin 
				print 'Thanh cong!'
			end
go

--2.2
create trigger trg22 
on PHANCONG
for insert, update
as
	declare @MaNV char(5), @MaXe char(5), @TenPhong varchar(25), @MaPhong char(5), @LoaiXe varchar(20)
	select @MaNV = I.MaNV, @TenPhong = PB.TenPhong, @MaPhong = NV.MaPhong
	from INSERTED as I, PHONGBAN as PB, NHANVIEN as NV
	where I.MaNV = NV.MaNV and NV.MaPhong = PB.MaPhong
	if(@TenPhong = 'Ngoai Thanh')
	begin
		select @LoaiXe = X.LoaiXe
		from INSERTED as I, XE as X
		where I.MaXe = X.MaXe
		if(@LoaiXe <> 'Toyota')
		begin 
			print 'Loi: Nhan vien phong Ngoai Thanh chi duoc phan cong xe Toyota'
			rollback transaction
		end
		else
		begin
			print 'Thanh cong!'
		end
	end
go

--3.1
select NV.MaNV, NV.HoTen 
from NHANVIEN as NV, PHONGBAN as PB, XE as X, PHANCONG as PC
where PB.MaPhong = NV.MaPhong and NV.MaNV = PC.MaNV and PC.MaXe = X.MaXe
and PB.TenPhong = 'Noi Thanh' and X.LoaiXe = 'Toyota' and X.SoChoNgoi = 4

--3.2--
select NV.MaNV, NV.HoTen 
from NHANVIEN as NV, PHONGBAN as PB
where PB.MaPhong = NV.MaPhong and PB.TruongPhong = NV.MaNV
and not exists (
	select * from XE as X
	where not exists (
		select * from PHANCONG as PC
		where PC.MaNV = NV.MaNV
		and PC.MaXe = X.MaXe
	)
)

--3.3
select NVA.MaNV, NVA.HoTen, NVA.MaPhong, count(PCA.MaXe)
from PHANCONG as PCA, NHANVIEN as NVA, XE as XA
where NVA.MaNV = PCA.MaNV and PCA.MaXe = XA.MaXe and XA.LoaiXe = 'Toyota'
group by NVA.MaNV, NVA.HoTen, NVA.MaPhong
having count(PCA.MaXe) <= (
	select count(PCB.MaXe) 
	from PHANCONG as PCB, NHANVIEN as NVB, XE as XB
	where PCB.MaNV = NVB.MaNV and PCB.MaXe = XB.MaXe and XB.LoaiXe = 'Toyota'
	group by NVB.MaPhong, NVB.MaNV
	having NVA.MaPhong = NVB.MaPhong
)


