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
having count(CTA.MaPT) >= (
	select count(CTB.MaPT) 
	from SACH as SB, PHIEUTHUE as PTB, CHITIET_PT as CTB
	where SB.MaSach = CTB.MaSach and CTB.MaPT = PTB.MaPT
	group by SB.TheLoai, SB.TenSach
	having SA.TheLoai = SB.TheLoai
)





