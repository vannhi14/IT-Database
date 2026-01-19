--De01--
create database TTHD1;
go
use TTHD1;
create table TACGIA
( 
	MaTG char(5) PRIMARY KEY,
	HoTen varchar(20),
	DiaChi varchar(50),
	NgSinh smalldatetime,
	SoDT varchar(15)
)
create table SACH
(
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25)
)
create table TACGIA_SACH
(
	MaTG char(5),
	MaSach char(5),
	constraint MaTG_MaSach PRIMARY KEY (MaTG, MaSach)
)
create table PHATHANH
(
	MaPH char(5) PRIMARY KEY,
	MaSach char(5),
	NgayPH smalldatetime,
	SoLuong int,
	NhaXuatBan varchar(20)
)

alter table TACGIA_SACH add
constraint TGS_MaTG foreign key (MaTG) references TACGIA(MaTG),
constraint TGS_MaSach foreign key (MaSach) references SACH(MaSach)

alter table PHATHANH add
constraint PH_MaSach foreign key (MaSach) references SACH(MaSach)
go

--2.1
create trigger trg21
on PHATHANH
for insert, update
as
	declare @NgayPH smalldatetime, @NgSinh smalldatetime
	select @NgayPH = NgayPH, @NgSinh = NgSinh
	from INSERTED as I, TACGIA as TG, TACGIA_SACH as TGS
	where I.MaSach = TGS.MaSach and TGS.MaTG = TG.MaTG
	if (@NgayPH < @NgSinh)
	begin
		print 'Loi: Ngay phat hanh khong hop le'
		rollback transaction
	end
	else 
	begin
		print 'Thanh cong!'
	end
go

--2.2
create trigger trg22
on PHATHANH
for insert, update
as
		declare  @NhaXuatBan varchar(20), @MaSach char(5), @TheLoai varchar(25)
		select @MaSach = MaSach, @NhaXuatBan = NhaXuatBan
		from INSERTED
		if (@NhaXuatBan <> 'Giao Duc')
		begin 
			select @TheLoai = TheLoai
			from INSERTED as I, SACH as S
			where I.MaSach = S.MaSach
			if (@TheLoai = 'Giao Khoa')
			begin
				print 'Loi: Sach Giao Khoa phai do NXB Giao Duc phat hanh'
				rollback transaction
			end
			else
			begin
				print 'Thanh cong!'
			end

--3.1
select TG.MaTG, TG.HoTen, TG.SoDT 
from TACGIA as TG, TACGIA_SACH as TGS, SACH as S, PHATHANH as PH
where TG.MaTG = TGS.MaTG and TGS.MaSach = S.MaSach and S.MaSach = PH.MaSach
and S.TheLoai = 'Van hoc' and PH.NhaXuatBan = 'NXB Tre'

--3.2
select top 1 with ties PH.NhaXuatBan 
from SACH as S, PHATHANH as PH
where S.MaSach = PH.MaSach 
group by PH.NhaXuatBan
order by count(S.TheLoai) desc

--3.3
select NhaXuatBan, TACGIA.MaTG, TACGIA.HoTen, count(MaPH)
from TACGIA, PHATHANH PHA, TACGIA_SACH
where TACGIA.MaTG = TACGIA_SACH.MaTG and TACGIA_SACH.MaSach = PHA.MaSach
group by NHAXUATBAN, TACGIA.MaTG, TACGIA.HoTen
having count(MAPH) >= all (
	select count(MAPH) 
	from TACGIA, PHATHANH PHB, TACGIA_SACH
	where TACGIA.MaTG = TACGIA_SACH.MaTG and TACGIA_SACH.MaSach = PHB.MaSach
	group by NHAXUATBAN, TACGIA.MaTG
	having PHB.NhaXuatBan = PHA.NhaXuatBan
)
--De02--
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
having count(PCA.MaXe) <= all(
	select count(PCB.MaXe) 
	from PHANCONG as PCB, NHANVIEN as NVB, XE as XB
	where PCB.MaNV = NVB.MaNV and PCB.MaXe = XB.MaXe and XB.LoaiXe = 'Toyota'
	group by NVB.MaPhong, NVB.MaNV
	having NVA.MaPhong = NVB.MaPhong
)

--De03--
create database TTHD3;
go
use TTHD3;
create table DOCGIA
(
	MaDG char(5) PRIMARY KEY,
	HoTen varchar(30),
	NgaySinh smalldatetime,
	DiaChi varchar(30),
	SoDT varchar(15)
)
create table SACH
(
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25),
	NhaXuatBan varchar(30),
)
create table PHIEUTHUE
(
	MaPT char(5) PRIMARY KEY,
	MaDG char(5),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	SoSachThue int
)

create table CHITIET_PT
(
	MaPT char(5),
	MaSach char(5),
	constraint MaPT_MaSach PRIMARY KEY (MaPT, MaSach)
)

alter table PHIEUTHUE add
constraint PT_MaDG foreign key (MaDG) references DOCGIA(MaDG)

alter table CHITIET_PM add
constraint CTPM_MaPM foreign key (MaPM) references PHIEUTHUE(MaPM),
constraint CTPM_MaSach foreign key (MaSach) references SACH(MaSach)

--2.1
alter table PHIEUTHUE add
constraint PT_SoNgay check (NgayTra - NgayThue <= 10)
go
--2.2--
create trigger trg22 
on CHITIET_PT
for insert, update 
as
	declare @MaPT char(5)
	select @MaPT = I.MaPT
	from INSERTED as I, PHIEUTHUE as PT
	where I.MaPT = PT.MaPT
	update PHIEUTHUE
	set SoSachThue = SoSachThue + 1
	print 'Da cap nhat so sach thue'

--3.1
select DG.MaDG, DG.HoTen 
from DOCGIA as DG, PHIEUTHUE as PT, CHITIET_PT as CTPT, SACH as S
where DG.MaDG = PT.MaPT and PT.MaPT = CTPT.MaPT and CTPT.MaSach = S.MaSach
and year(PT.NgayThue) = 2007 and S.TheLoai = 'Tin hoc'

--3.2
select top 1 with ties DG.MaDG, DG.HoTen 
from DOCGIA as DG, PHIEUTHUE as PT, CHITIET_PT as CTPT, SACH as S
where DG.MaDG = PT.MaPT and PT.MaPT = CTPT.MaPT and CTPT.MaSach = S.MaSach
group by DG.MaDG, DG.HoTen 
order by count(S.TheLoai) desc

--3.3
select SA.TheLoai, SA.TenSach, count(CTA.MaPT)
from SACH as SA, PHIEUTHUE as PTA, CHITIET_PT as CTA
where SA.MaSach = CTA.MaSach and CTA.MaPT = PTA.MaPT
group by SA.TheLoai, SA.TenSach
having count(CTA.MaPT) >= all (
	select count(CTB.MaPT) 
	from SACH as SB, PHIEUTHUE as PTB, CHITIET_PT as CTB
	where SB.MaSach = CTB.MaSach and CTB.MaPT = PTB.MaPT
	group by SB.TheLoai, SB.TenSach
	having SA.TheLoai = SB.TheLoai
)

--De04--
create database TTHD4;
go
use TTHD4;

create table KHACHHANG
(
	MaKH char(5) PRIMARY KEY,
	HoTen varchar(30),
	DiaChi varchar(30),
	SoDT varchar(15),
	LoaiKH varchar(10)
)

create table BANG_DIA
(
	MaBD char(5) PRIMARY KEY,
	TenBD varchar(25),
	TheLoai varchar(25)
)

create table PHIEUTHUE
(
	MaPT char(5) PRIMARY KEY,
	MaKH char(5),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	Soluongthue int
)

create table CHITIET_PM
(
	MaPT char(5),
	MaBD char(5),
	constraint MaPT_MaBD PRIMARY KEY (MaPT, MaBD)
)

alter table PHIEUTHUE add
constraint PT_MaKH foreign key (MaKH) references KHACHHANG(MaKH)

alter table CHITIET_PM add
constraint CTPM_MaPT foreign key (MaPT) references PHIEUTHUE(MaPT),
constraint CTPM_MaBD foreign key (MaBD) references BANG_DIA(MaBD)
go

--2.1
alter table BANG_DIA add
constraint BD_TheLoai check (TheLoai in ('ca nhac', 'phim hanh dong', 'phim tinh cam', 'phim hoat hinh'))
go

--2.2
create trigger trg22
on PHIEUTHUE
for insert
as
	declare @MaKH char(5), @Soluongthue int, @LoaiKH varchar(10)
	select @MaKH = MaKH, @Soluongthue = Soluongthue
	from INSERTED 
	if (@Soluongthue > 5)
	begin 
		select @LoaiKH = KH.LoaiKH
		from INSERTED as I, KHACHHANG as KH
		where I.MaKH = KH.MaKH
		if (@LoaiKH <> 'VIP')
		begin
			print 'Loi: Khach hang khong thuoc VIP khong duoc thue qua 5 san pham'
			rollback transaction
		end
		else
		begin
			print 'Thanh cong!'
		end
	end
go

--3.1
select KH.MaKH, KH.HoTen 
from KHACHHANG as KH, PHIEUTHUE as PT, CHITIET_PM as CTPM, BANG_DIA as BD 
where KH.MaKH = PT.MaKH and PT.MaPT = CTPM.MaPT and CTPM.MaBD = BD.MaBD
and BD.TheLoai = 'phim tinh cam' and PT.Soluongthue = 3

--3.2
select top 1 with ties KH.MaKH, KH.HoTen 
from KHACHHANG as KH, PHIEUTHUE as PT
where KH.MaKH = PT.MaKH and KH.LoaiKH = 'VIP'
group by KH.MaKH, KH.HoTen
order by count(PT.MaPT) desc

--3.3
select BDA.TheLoai, KHA.HoTen, count(CTA.MaPT)
from BANG_DIA as BDA, PHIEUTHUE as PTA, CHITIET_PM as CTA, KHACHHANG as KHA
where KHA.MaKH = PTA.MaKH and PTA.MaPT = CTA.MaPT and CTA.MaBD = BDA.MaBD
group by BDA.TheLoai, KHA.HoTen
having count(CTA.MaPT) >= all(
	select count(CTB.MaPT)
	from BANG_DIA as BDB, PHIEUTHUE as PTB, CHITIET_PM as CTB, KHACHHANG as KHB
	where KHB.MaKH = PTB.MaKH and PTB.MaPT = CTB.MaPT and CTB.MaBD = BDB.MaBD
	group by BDB.TheLoai, KHB.HoTen
	having BDA.TheLoai = BDB.TheLoai
)
