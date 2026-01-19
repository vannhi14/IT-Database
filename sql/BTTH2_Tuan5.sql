/*
create database BTTH2T2;
go 
use BTTH2T2;

create table HOCVIEN
(
	MAHV char(5) PRIMARY KEY,
	HO varchar(40),
	TEN varchar(10),
	NGSINH smalldatetime,
	GIOITINH varchar(3),
	NOISINH varchar(40),
	MALOP char(3),
)

create table GIAOVIEN
(
	MAGV char(4) PRIMARY KEY,
	HOTEN varchar(40),
	HOCVI varchar(10),
	HOCHAM varchar(10),
	GIOITINH varchar(3),
	NGSINH smalldatetime,
	NGVL smalldatetime,
	HESO numeric(4,2),
	MUCLUONG money,
	MAKHOA varchar(4),
)

create table KHOA
(
	MAKHOA varchar(4) PRIMARY KEY,
	TENKHOA varchar(40),
	NGTLAP smalldatetime,
	TRGKHOA char(4),
)

create table LOP 
(
	MALOP char(3) PRIMARY KEY,
	TENLOP varchar(40),
	TRGLOP char(5),
	SISO tinyint,
	MAGVCN char(4),
)

create table MONHOC 
(
	MAMH varchar(10) PRIMARY KEY,
	TENMH varchar(40),
	TCLT tinyint,
	TCTH tinyint,
	MAKHOA varchar(4),
)

create table DIEUKIEN 
(
	MAMH varchar(10),
	MAMH_TRUOC varchar(10),
	constraint MAMH_MAMHTRUOC PRIMARY KEY (MAMH, MAMH_TRUOC),
)

create table GIANGDAY 
(
	MALOP char(3),
	MAMH varchar(10),
	MAGV char(4),
	HOCKY tinyint,
	NAM smallint,
	TUNGAY smalldatetime,
	DENNGAY smalldatetime,
	constraint MALOP_MAMH PRIMARY KEY (MALOP, MAMH),
)

create table KETQUATHI
(
	MAHV char(5),
	MAMH varchar(10),
	LANTHI tinyint,
	NGTHI smalldatetime,
	DIEM numeric(4,2),
	KQUA varchar(10),
	constraint MAHV_MAMH_LANTHI PRIMARY KEY (MAHV, MAMH, LANTHI),
)

--1
alter table HOCVIEN add
constraint HV_MALOP foreign key (MALOP) references LOP(MALOP)

alter table GIAOVIEN add
constraint GV_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)

alter table KHOA add
constraint KHOA_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)

alter table LOP add
constraint LOP_TRGLOP foreign key (TRGLOP) references HOCVIEN(MAHV),
constraint LOP_MAGVCN foreign key (MAGVCN) references GIAOVIEN(MAGV)

alter table MONHOC add
constraint MH_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)

alter table DIEUKIEN add
constraint DK_MAMH foreign key (MAMH) references MONHOC(MAMH),
constraint DK_MAMHTRC foreign key (MAMH_TRUOC) references MONHOC(MAMH)

alter table GIANGDAY add
constraint GD_MALOP foreign key (MALOP) references LOP(MALOP),
constraint GD_MAMH foreign key (MAMH) references MONHOC(MAMH),
constraint GD_MAGV foreign key (MAGV) references GIAOVIEN(MAGV)

alter table KETQUATHI add
constraint KQ_MAHV foreign key (MAHV) references HOCVIEN(MAHV),
constraint KQ_MAMH foreign key (MAMH) references MONHOC(MAMH)

alter table HOCVIEN add GHICHU  varchar(20) NULL DEFAULT(NULL)
alter table HOCVIEN add DIEMTB numeric(4,2) NULL DEFAULT(NULL)
alter table HOCVIEN add XEPLOAI varchar(20) NULL DEFAULT(NULL)

--2
--3
alter table HOCVIEN add
constraint GT_HV check (GIOITINH in ('Nam', 'Nu'))
alter table GIAOVIEN add
constraint GT_GV check (GIOITINH in ('Nam', 'Nu'))
--4
alter table  KETQUATHI add
constraint DIEM_KQT check (DIEM >= 0 and DIEM <= 10) 
select ROUND(DIEM, 2) from KETQUATHI
--5
alter table KETQUATHI add
constraint KETQUA_KQT 
check ((KQUA = 'Dat' and DIEM >= 5 and DIEM <= 10) or (KQUA = 'Khong dat' and DIEM < 5))
--6
alter table KETQUATHI add
constraint LANTHI_KQT check (LANTHI > 0 and LANTHI <= 3)
--7
alter table GIANGDAY add
constraint HOCKY_GD check (HOCKY > 0 and HOCKY <=3)
--8
alter table GIAOVIEN add
constraint HOCVI_GV check (HOCVI in ('CN', 'KS', 'Ths', 'TS', 'PTS'))
--9
--10
--11
alter table HOCVIEN add
constraint NGSINH_HV check (YEAR(GETDATE()) - YEAR(NGSINH) >= 18)
--12
alter table GIANGDAY add
constraint NG_GD check (TUNGAY < DENNGAY)
--13
alter table GIAOVIEN add
constraint NG_GV check (YEAR(NGVL) - YEAR(NGSINH) >= 22)
--14
alter table MONHOC add
constraint TINCHI_MH check (ABS(TCLT - TCTH) <= 3)

--II
--1
update GIAOVIEN 
set HESO = HESO + 0.2 where GIAOVIEN.MAGV in(select KHOA.TRGKHOA from KHOA)
--2
update HOCVIEN
set DIEMTB =
(
	select AVG(DIEM)
	from KETQUATHI as KQT1
	where LANTHI = (select MAX(LANTHI) from KETQUATHI as KQT2 where KQT1.MAHV = KQT2.MAHV group by MAHV)
	group by MAHV
	having MAHV = HOCVIEN.MAHV
)
--3
update HOCVIEN
set GHICHU = 'Cam thi' where HOCVIEN.MAHV 
in (select KETQUATHI.MAHV from KETQUATHI where KETQUATHI.LANTHI = 3 and KETQUATHI.DIEM < 5)
--4
update HOCVIEN
set XEPLOAI =
(
	case 
		when DIEMTB >= 9 then 'XS'
		when DIEMTB >= 8 and DIEMTB < 9 then 'G'
		when DIEMTB >= 6.5 and DIEMTB < 8 then 'K'
		when DIEMTB >= 5 and DIEMTB < 6.5 then 'TB'
		when DIEMTB < 5 then 'Y'
	end
)
--III
--1
select HV.MAHV, HV.HO, HV.TEN, HV.NGSINH, HV.MALOP from HOCVIEN as HV, LOP as L 
where HV.MAHV = L.TRGLOP
--2
select HV.MAHV, HV.HO, HV.TEN, KQ.LANTHI, KQ.DIEM from HOCVIEN as HV, KETQUATHI as KQ 
where HV.MAHV = KQ.MAHV and KQ.MAMH = 'CTRR' and HV.MALOP = 'K12'
order by HV.TEN, HV.HO
--3
select HV.MAHV, HV.HO, HV.TEN, MH.TENMH from HOCVIEN as HV, MONHOC as MH, KETQUATHI as KQ
where HV.MAHV = KQ.MAHV and MH.MAMH = KQ.MAMH and KQ.LANTHI = 1 and KQUA = 'Dat'
--4
select HV.MAHV, HV.HO, HV.TEN from HOCVIEN as HV, KETQUATHI as KQ
where HV.MAHV = KQ.MAHV and KQ.MAMH = 'CTRR' and HV.MALOP = 'K11' and KQ.LANTHI = 1 and KQUA = 'Khong dat'
--5
--6
select MH.TENMH from MONHOC as MH, GIAOVIEN as GV, GIANGDAY as GD
where GV.MAGV = GD.MAGV and GD.MAMH = MH.MAMH 
and GV.HOTEN = 'Tran Tam Thanh' and GD.HOCKY = '1' and GD.NAM = '2006'
--7
select MH.MAMH, MH.TENMH from MONHOC as MH, GIAOVIEN as GV, LOP as L, GIANGDAY as GD
where MH.MAMH = GD.MAMH and GD.MAGV = GV.MAGV and GV.MAGV = L.MAGVCN
and L.MALOP = 'K11' and GD.HOCKY = 1 and GD.NAM ='2006'
--8
select HV.HO, HV.TEN from HOCVIEN as HV, LOP as L, GIAOVIEN as GV, GIANGDAY as GD, MONHOC as MH
where HV.MAHV = L.TRGLOP and L.MALOP = GD.MALOP and GD.MAGV = GV.MAGV and GD.MAMH = MH.MAMH
and GV.HOTEN = 'Nguyen To Lan' and MH.TENMH = 'Co So Du Lieu'
--9
select MHT.MAMH, MHT.TENMH from MONHOC as MH, MONHOC as MHT, DIEUKIEN as DK
where MH.MAMH = DK.MAMH and MHT.MAMH = DK.MAMH_TRUOC and MH.TENMH = 'Co So Du Lieu'
--10
select MH.MAMH, MH.TENMH from MONHOC as MH, MONHOC as MHT, DIEUKIEN as DK
where MH.MAMH = DK.MAMH and MHT.MAMH = DK.MAMH_TRUOC and MHT.TENMH = 'Cau Truc Roi Rac'
--11
select GV.HOTEN from GIAOVIEN as GV, GIANGDAY as GD 
where GV.MAGV = GD.MAGV and GD.MAMH = 'CTRR' and GD.MALOP = 'K11' and GD.HOCKY = 1 and GD.NAM = 2006
intersect
select GV.HOTEN from GIAOVIEN as GV, GIANGDAY as GD 
where GV.MAGV = GD.MAGV and GD.MAMH = 'CTRR' and GD.MALOP = 'K12' and GD.HOCKY = 1 and GD.NAM = 2006
--12
select HV.MAHV, HV.HO, HV.TEN from HOCVIEN as HV, KETQUATHI as KQ, MONHOC as MH
where HV.MAHV = KQ.MAHV and  MH.MAMH = KQ.MAMH 
and MH.TENMH = 'Co So Du Lieu' and KQ.KQUA = 'Khong Dat' 
and KQ.MAHV not in (
		select KQT.MAHV from KETQUATHI as KQT, MONHOC as MH
		where KQT.MAMH = MH.MAMH and MH.TENMH = 'Co So Du Lieu' and KQT.LANTHI > 1)
--13
select GV.MAGV, GV.HOTEN from GIAOVIEN as GV
where GV.MAGV not in (
		select GD.MAGV from GIANGDAY as GD )
--14
select GV.MAGV, GV.HOTEN from GIAOVIEN as GV
where GV.MAGV not in (
			select GV.MAGV from GIANGDAY as GD, MONHOC as MH, GIAOVIEN as GV
			where GV.MAGV = GD.MAGV and GD.MAMH = MH.MAMH and GV.MAKHOA = MH.MAKHOA )
--15
select HV.MAHV, HV.HO, HV.TEN from HOCVIEN as HV, MONHOC as MH, KETQUATHI as KQ
where HV.MALOP = 'K11' and KQ.MAHV = HV.MAHV and KQ.MAMH = MH.MAMH 
and KQ.LANTHI >= 3 and KQ.KQUA = 'Khong Dat'
or HV.MALOP = 'K11' and KQ.MAHV = HV.MAHV 
and KQ.MAMH = 'CRTT' and KQ.LANTHI = 2 and KQ.DIEM = 5
--16
select GV.HOTEN from GIAOVIEN as GV, GIANGDAY as GD
where GV.MAGV = GD.MAGV and GD.MAMH = 'CTRR' 
group by GV.HOTEN, GD.HOCKY
having count (GD.MALOP) >= 2
--17
select HV.MAHV, HV.HO, HV.TEN, KQLT.DIEM from HOCVIEN as HV, KETQUATHI as KQLT
where HV.MAHV = KQLT.MAHV and KQLT.MAMH = 'CSDL' and KQLT.MAMH not in (
	select KQLS.MAMH
	from KETQUATHI as KQLS
	where KQLT.MAHV = KQLS.MAHV and KQLT.MAMH = KQLS.MAMH and KQLT.LANTHI < KQLS.LANTHI)
group by HV.MAHV, HV.HO, HV.TEN, KQLT.DIEM 
--18
select HV.MAHV, HV.HO, HV.TEN, max(KQ.DIEM) as DIEMCHINHTHUC 
from HOCVIEN as HV, KETQUATHI as KQ, MONHOC as MH
where HV.MAHV = KQ.MAHV and KQ.MAMH = MH.MAMH and MH.TENMH = 'Co So Du Lieu'
group by HV.MAHV, HV.HO, HV.TEN
--19
select K.MAKHOA, K.TENKHOA from KHOA as K 
where YEAR(K.NGTLAP) = (
	select min(YEAR(NGTLAP)) from KHOA)
--20
select HOCHAM, count(HOCHAM) as SL from GIAOVIEN
where HOCHAM in ('GS', 'PGS')
group by HOCHAM
--21
select K.MAKHOA, GV.HOCVI, count(GV.HOCVI) SL from GIAOVIEN as GV, KHOA as K
where GV.MAKHOA = K.MAKHOA and GV.HOCVI in ('CN', 'KS', 'ThS', 'TS', 'PTS')
group by K.MAKHOA, GV.HOCVI
order by K.MAKHOA
--22
select MAMH, KQUA, count(MAHV) as SL from KETQUATHI
group by MAMH, KQUA
--23
select distinct GV.MAGV, GV.HOTEN from GIAOVIEN as GV, GIANGDAY as GD, LOP as L
where GV.MAGV = L.MAGVCN and GD.MAGV = GV.MAGV and GD.MALOP = L.MALOP
--24
select HV.HO, HV.TEN from LOP as L, HOCVIEN as HV
where L.TRGLOP = HV.MAHV and SISO = (
	select max(SISO) from LOP) 
--25
select HV.HO, HV.TEN from HOCVIEN as HV, LOP as L
where HV.MAHV = L.TRGLOP and HV.MAHV in (
	select KQA.MAHV from KETQUATHI as KQA
	where not exists (
		select * from KETQUATHI as KQB 
		where KQA.MAHV = KQB.MAHV and KQA.MAMH = KQB.MAMH and KQA.LANTHI < KQB.LANTHI)
		and KQA.KQUA = 'Khong Dat'
	group by MAHV
	having count(KQA.MAMH) >= 3
)
--26
select top 1 with ties HV.MAHV, HV.HO, HV.TEN
from KETQUATHI as KQ, HOCVIEN as HV
where KQ.MAHV = HV.MAHV and DIEM >= 9 and DIEM <= 10
group by HV.MAHV, HV.HO, HV.TEN
order by count(KQ.MAMH) desc
--27 
select HVA.MAHV, HVA.HO, HVA.TEN, HVA.MALOP
from HOCVIEN HVA, KETQUATHI as KQA
where HVA.MAHV = KQA.MAHV and KQA.DIEM >= 9 and KQA.DIEM <= 10
group by HVA.MAHV, HVA.HO, HVA.TEN, HVA.MALOP
having count(KQA.DIEM) >= all(
	select count(KQB.DIEM)
	from HOCVIEN HVB, KETQUATHI as KQB
	where KQB.MAHV = HVB.MAHV
	and HVB.MALOP = HVA.MALOP
	and KQB.DIEM >= 9 and KQB.DIEM >= 10
	group by HVB.MAHV
)
--28
select GD.HOCKY, GD.MAGV, GD.NAM, count(distinct GD.MAMH) as SOMON, count(distinct GD.MALOP) as SOLOP 
from GIANGDAY as GD
group by GD.HOCKY, GD.MAGV, GD.NAM
--29
select GDA.MAGV, GVA.HOTEN, GDA.HOCKY, GDA.NAM
from GIAOVIEN as GVA, GIANGDAY as GDA
where GVA.MAGV = GDA.MAGV 
group by GDA.MAGV, GVA.HOTEN, GDA.HOCKY, GDA.NAM 
having count(GDA.MAMH) >= all (
	select count(GDB.MAMH) from GIAOVIEN as  GVB, GIANGDAY as GDB
	where GVB.MAGV = GDB.MAGV 
	and GDB.HOCKY = GDA.HOCKY 
	and GDB.NAM = GDA.NAM
	group by GVB.MAGV
)
--30 
select top 1 with ties KQ.MAMH, MH.TENMH from KETQUATHI as KQ, MONHOC as MH
where KQ.MAMH = MH.MAMH and KQ.LANTHI = 1 and KQ.KQUA = 'Khong Dat'
group by KQ.MAMH,  MH.TENMH
order by count(KQ.MAHV) desc

--31 
select KQ.MAHV, HV.HO, HV.TEN, count(KQ.KQUA) as MONTHI from KETQUATHI as KQ, HOCVIEN as HV
where HV.MAHV = KQ.MAHV
and KQ.LANTHI = 1 and KQ.KQUA = 'Dat'
group by KQ.MAHV, HV.HO, HV.TEN
intersect
select KQ.MAHV, HV.HO, HV.TEN, count(KQ.MAMH) as DANGKY from KETQUATHI as KQ, HOCVIEN as HV
where HV.MAHV = KQ.MAHV 
and KQ.LANTHI = 1 
group by KQ.MAHV, HV.HO, HV.TEN

--32
select KQA.MAHV, HV.HO, HV.TEN, count(KQA.KQUA) as MONTHI from KETQUATHI as KQA, HOCVIEN as HV
where HV.MAHV = KQA.MAHV
and KQA.KQUA = 'Dat' and not exists (
		select * from KETQUATHI KQB 
		where KQA.MAHV = KQB.MAHV and KQA.MAMH = KQB.MAMH and KQA.LANTHI < KQB.LANTHI) 
group by KQA.MAHV, HV.HO, HV.TEN
intersect
select KQ.MAHV, HV.HO, HV.TEN, count(KQ.MAMH) as DANGKY from KETQUATHI as KQ, HOCVIEN as HV
where HV.MAHV = KQ.MAHV
and KQ.LANTHI = 1 
group by KQ.MAHV, HV.HO, HV.TEN

--33
select HV.MAHV, HV.HO, HV.TEN from HOCVIEN as HV
where not exists (
	select * from KETQUATHI as KQA, MONHOC as MH
	where KQA.MAMH = MH.MAMH
	and not exists(
		select * from KETQUATHI as KQB
		where MH.MAMH = KQB.MAMH	
		and KQB.MAHV = HV.MAHV
		and KQB.KQUA = 'Dat' and KQB.LANTHI = 1
		)
	)
--34
select HV.MAHV, HV.HO, HV.TEN from HOCVIEN as HV
where not exists (
	select * from KETQUATHI as KQA, MONHOC as MH
	where KQA.MAMH = MH.MAMH
	and not exists(
		select * from KETQUATHI as KQB
		where MH.MAMH = KQB.MAMH	
		and KQB.MAHV = HV.MAHV
		and KQB.KQUA = 'Dat' and KQB.LANTHI = (
			select max(LANTHI) from KETQUATHI
			where  KETQUATHI.MAHV = HV.MAHV)
		)
	)
--35
*/
--I
--9
create trigger trg9 on LOP
for update
as
	declare @MALOPA char(3), @MALOPB char(3)
	select @MALOPA = A.MALOP, @MALOPB = B.MALOP
	from INSERTED as A, HOCVIEN as B
	where A.TRGLOP = B.MAHV
	if (@MALOPA <> @MALOPB)
	begin
		print 'Loi: Lop truong cua mot lop phai la hoc vien lop do'
	end
	else
	begin
		print 'Them lop truong thanh cong'
	end
--10
create trigger trg10 on KHOA
for update
as
	declare @MAKHOAA varchar(4), @MAKHOAB varchar(4), @HOCVI varchar(10)
	select @MAKHOAA = A.MAKHOA, @MAKHOAB = B.MAKHOA, @HOCVI = HOCVI
	from INSERTED as A, GIAOVIEN as B
	where A.TRGKHOA = B.MAGV
	if (@MAKHOAA <> @MAKHOAB)
	begin
		print 'Loi: Truong khoa cua mot khoa phai la giao vien khoa do'
		rollback transaction
	end
	else
	if (@HOCVI <> 'TS' and @HOCVI <> 'PTS')
	begin
		print 'Loi: Truong khoa cua mot khoa phai la giao vien khoa do'
		rollback transaction
	end
	else
	begin
		print 'Them truong khoa thanh cong'
	end
--15
create trigger trg15
on KETQUATHI
for insert, update
as
	declare @NGTHI smalldatetime, @DENNGAY smalldatetime
	select @NGTHI = NGTHI, @DENNGAY = DENNGAY
	from INSERTED as I, HOCVIEN as HV, GIANGDAY as GD
	where I.MAHV = HV.MAHV and I.MAMH = GD.MAMH and HV.MALOP = GD.MALOP
	if (@NGTHI < @DENNGAY)
	begin
		print 'Loi: Hoc vien khong duoc thi mon lop chua hoc xong'
		rollback transaction
	end
	else 
	begin
	print 'Them ngay thi thanh cong!'
	end
--16
create trigger trg16 on GIANGDAY
for insert, update
as
	declare @SLMONHOC int
	select @SLMONHOC = count(GD.MAMH)
	from INSERTED I, GIANGDAY as GD
	where I.MALOP = GD.MALOP and I.HOCKY = GD.HOCKY and I.NAM = GD.NAM
	if (@SLMONHOC > 3)
	begin
		print 'Loi: Mot lop khong duoc hoc qua 3 mon 1 ky'
		rollback transaction
	end
	else 
	begin
	print 'Dang ky mon cho lop thanh cong!'
	end
--17
create trigger trg17
on LOP
for insert
as 
	declare @MALOPI char(3)
	select @MALOPI = I.MALOP
	from INSERTED as I
	where MALOP = I.MALOP
	update LOP
	set SISO = SISO+1
	print 'Da update si so cua lop'
--18
--19
create trigger trg19
on GIAOVIEN
for insert, update
as
	declare @MAGV char(4), @MUCLUONG money
	select @MAGV = I.MAGV, @MUCLUONG = GV.MUCLUONG
	from  INSERTED as I, GIAOVIEN as GV
	where I.HOCVI = GV.HOCVI and I.HOCHAM = GV.HOCHAM 
	and I.HESO = GV.HESO and I.MAGV <> GV.MAGV
	update GIAOVIEN
	set MUCLUONG = @MUCLUONG
	where MAGV = @MAGV
	print 'Da update muc luong cua cac giao vien'
--20
create trigger trg20
on KETQUATHI
for insert, update
as
	declare @LANTHI tinyint, @DIEM numeric(4,2)
	select @LANTHI = LANTHI, @DIEM = DIEM
	from INSERTED
	if (@LANTHI > 1)
	begin 
		select @DIEM = KQ.DIEM
		from INSERTED I, KETQUATHI KQ
		where I.MAHV = KQ.MAHV and I.MAMH = KQ.MAMH and KQ.LANTHI = @LANTHI-1
		if(@DIEM >= 5)
		begin
			print 'Loi: Hoc vien da dat diem tu 5 tro len mon nay'
			rollback transaction
		end
		else
		begin
			print 'Dang ky thi lai thanh cong!'
		end
	end
--21
create trigger trg21
on KETQUATHI
for insert, update
as
	declare @LANTHI tinyint, @NGTHIA smalldatetime, @NGTHIB smalldatetime
	select @LANTHI = LANTHI
	from INSERTED
	if(@LANTHI > 1)
	begin 
		select @NGTHIA = I.NGTHI, @NGTHIB = KQ.NGTHI
		from INSERTED I, KETQUATHI KQ
		where I.MAHV = KQ.MAHV and I.MAMH = KQ.MAMH and I.LANTHI < KQ.LANTHI
		if(@NGTHIA > @NGTHIB)
		begin
			print 'Loi: Ngay thi lai truoc khong duoc lon hon ngay thi sau'
			rollback transaction
		end
		else
		begin
			print 'Dang ky thi lai thanh cong!'
		end
	end
--22
create trigger trg22
on KETQUATHI
for insert, update
as
	declare @NGTHI smalldatetime, @DENNGAY smalldatetime
	select @NGTHI = NGTHI, @DENNGAY = DENNGAY
	from INSERTED as I, HOCVIEN as HV, GIANGDAY as GD
	where I.MAMH = GD.MAMH and HV.MALOP = GD.MALOP
	if (@NGTHI < @DENNGAY)
	begin
		print 'Loi: Hoc vien khong duoc thi mon nay'
		rollback transaction
	end
	else 
	begin
	print 'Dang ky mon thi thanh cong!'
	end
--23
--24
create trigger trg24 
on GIANGDAY
for insert, update
as
	declare @MAKHOAA varchar(4), @MAKHOAB varchar(4)
	select @MAKHOAA = GV.MAKHOA, @MAKHOAB = MH.MAKHOA
	from INSERTED as I, GIAOVIEN as GV, MONHOC as MH
	where I.MAGV = GV.MAGV and I.MAMH = MH.MAMH
	if (@MAKHOAA <> @MAKHOAB)
	begin
		print 'Loi: Giang vien chi duoc phan cong giang day mon khoa cua giang vien do phu trach'
		rollback transaction
	end
	else
	begin
		print 'Phan cong giang day thanh cong'
	end



