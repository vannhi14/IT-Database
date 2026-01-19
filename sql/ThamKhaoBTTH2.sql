use QLyGiaoVu
GO


--III.5 Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần
-- thi).
select distinct HV.MAHV, (HO+' '+TEN) HOTEN
from HOCVIEN HV, KETQUATHI KQT
where
	HV.MAHV = KQT.MAHV
	and MALOP like 'K%'
	and MAMH = 'CTRR'
	and not exists(
		select *
		from KETQUATHI
		where(
			KQUA = 'Dat'
			and MAMH = 'CTRR'
			and MAHV = HV.MAHV
		)
	)
GO


--III.6 Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006
select distinct TENMH
from MONHOC
where MAMH in (
	select distinct MAMH
	from GIANGDAY GD inner join GIAOVIEN GV on GD.MAGV = GV.MAGV
	where (
		HOTEN = 'Tran Tam Thanh' 
		and HOCKY = 1
		and NAM = 2006
	)
)
GO


--III.7 Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học
--      kỳ 1 năm 2006.
select MAMH, TENMH
from MONHOC
where MAMH in (
	select distinct MAMH 
	from GIANGDAY
	where MAGV in (
		select MAGVCN 
		from LOP
		where MALOP = 'K11'
	)
	and HOCKY = 1
	and NAM = 2006
)
GO

--III.8 Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.select distinct (HO+' '+TEN) HOTEN
from HOCVIEN HV, LOP L, GIAOVIEN GV, GIANGDAY GD, MONHOC MH
where(
	L.TRGLOP = HV.MAHV
	and GD.MALOP = L.MALOP
	and GD.MAGV = GV.MAGV
	and GD.MAMH = MH.MAMH
	and HOTEN = 'Nguyen To Lan'
	and TENMH = 'Co So Du Lieu'
)
GO



--III.9 In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
select MAMH, TENMH
from MONHOC
where MAMH in (
	select MAMH_TRUOC 
	from DIEUKIEN
	where MAMH in (
		select MAMH
		from MONHOC
		where TENMH = 'Co So Du Lieu'
	)
)
GO

--III.10 Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên
--       môn học) nào
select MAMH, TENMH 
from MONHOC
where MAMH in (
	select MAMH 
	from DIEUKIEN
	where MAMH_TRUOC in (
		select MAMH 
		from MONHOC
		where TENMH = 'Cau Truc Roi Rac'
	)
)
GO

--III.11 Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.select HOTEN
from GIAOVIEN GV1, GIANGDAY GD1
where
	GV1.MAGV = GD1.MAGV
	and MALOP = 'K11'
	and HOCKY = 1 
	and NAM = 2006
intersect(
	select HOTEN
	from GIAOVIEN GV2, GIANGDAY GD2
	where
		GV2.MAGV = GD2.MAGV
		and MALOP = 'K12'
		and HOCKY = 1
		and NAM = 2006
	)

GO


--III.12 Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi
--       lại môn này.
select HV.MAHV, (HO+' '+TEN) HOTEN
from HOCVIEN HV, KETQUATHI KQT
where 
	HV.MAHV = KQT.MAHV
	and MAMH = 'CSDL'
	and LANTHI = 1
	and KQUA = 'Khong Dat'
	and not exists(
		select *
		from KETQUATHI KQT2
		where  (
			LANTHI > 1
			and KQT2.MAHV = HV.MAHV
		)
	)
GO

--III.13 Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
select MAGV, HOTEN
from GIAOVIEN
where MAGV not in (
	select MAGV
	from GIANGDAY
)
GO
--III.14 Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc
--       khoa giáo viên đó phụ trách.select MAGV, HOTEN
FROM GIAOVIEN
where MAGV not in (
	select GD.MAGV
	from GIANGDAY GD inner join GIAOVIEN GV 
	on GD.MAGV = GV.MAGV inner join MONHOC MH on GD.MAMH = MH.MAMH
	where GV.MAKHOA = MH.MAKHOA
)
GO


--III.15 Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần
--       thứ 2 môn CTRR được 5 điểm.
select distinct (HO+' '+TEN) HOTEN
from HOCVIEN HV1, KETQUATHI KQT1
where (
	HV1.MAHV = KQT1.MAMH
	and MALOP = 'K11'
	and (
		(LANTHI = 2 
		and DIEM = 5)
		OR (
		select distinct MAHV
		from KETQUATHI KQT2
		where KQUA = 'Khong Dat'
		having count(*) > 3
	))
)
GO

--III.16 Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
select HOTEN
from GIAOVIEN GV, GIANGDAY GD
where
	GV.MAGV = GD.MAGV
	and MAMH = 'CTRR'
group by GV.MAGV, HOTEN, HOCKY
having count(*) >= 2
GO

--III.17 Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
select HV.*, DIEM as 'Diem thi'
from HOCVIEN HV, KETQUATHI KQT1
where (
	HV.MAHV = KQT1.MAHV
	and MAMH = 'CSDL'
	and LANTHI = (
		select max(LANTHI)
		from KETQUATHI KQT2
		where MAMH = 'CSDL' and KQT2.MAHV = HV.MAHV
		group by MAHV
	)
)
GO

--III.18 Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
select HV.MAHV, (HO+' '+TEN) HOTEN, DIEM
from HOCVIEN HV inner join (
	select MAHV, MAX(DIEM) DIEM 
	from KETQUATHI
	where MAMH in (
		select MAMH 
		from MONHOC
		where TENMH = 'Co So Du Lieu'
	)
	group by MAHV, MAMH
) DIEM_CSDL
on HV.MAHV = DIEM_CSDL.MAHV
GO

--III.19 Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.
select MAKHOA, TENKHOA
from KHOA
where NGTLAP = (select min(NGTLAP) from KHOA)
GO

--III.20 Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
select count(*) 
from GIAOVIEN
where HOCHAM in ('GS', 'PGS')
GO

--III.21 Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa.
select MAKHOA, HOCVI, count(*)
from GIAOVIEN
group by MAKHOA, HOCVI
order by MAKHOA
GO

--III.22 Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).select MAMH, KQUA, COUNT(*)
from KETQUATHI
where KQUA in ('Dat', 'Khong Dat')
GROUP BY MAMH, KQUA
order by MAMH
GO


--III.23 Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít
--		 nhất một môn học.
select distinct GV.MAGV, HOTEN
from GIAOVIEN GV, LOP, GIANGDAY GD
where(
	GD.MALOP = LOP.MALOP
	and GD.MAGV = GV.MAGV
	and GV.MAGV = LOP.MAGVCN
)
GO


--III.24 Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.
select (HO+' '+TEN) HOTEN
from HOCVIEN HV, LOP
where 
	  HV.MAHV = LOP.TRGLOP
	  and LOP.SISO = (select max(SISO) from LOP)
GO


--III.25 Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).
SELECT (HO+' '+TEN) AS HOTEN
FROM HOCVIEN HV
JOIN LOP ON HV.MAHV = LOP.TRGLOP
JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE KQT.KQUA = 'Khong Dat'
GROUP BY HV.MAHV, HO, TEN
HAVING COUNT(*) > 3;
GO
--III.26 Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
select top 1 with ties HV.MAHV, (HO+' '+TEN) HOTEN
from HOCVIEN HV, KETQUATHI KQT
where(
	HV.MAHV = KQT.MAHV
	and DIEM >= 9
	)
group by HV.MAHV, HO, TEN
order by count(*) desc
GO

--III.27 Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9,10 nhiều nhất.
select left(A.MAHV, 3) MALOP, A.MAHV, (HO+' '+TEN) HOTEN
from (
	select MAHV, rank() over (order by count(MAMH) desc) rank_MH from KETQUATHI KQT
	where DIEM between 9 and 10
	group by KQT.MAHV
	)A inner join HOCVIEN HV on A.MAHV = HV.MAHV
where rank_MH = 1
group by left(A.MAHV,3), A.MAHV, HO, TEN
GO

--III.28 Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp.
SELECT MaGV, COUNT(DISTINCT MaMH), COUNT(DISTINCT MALOP) 
FROM GiangDay
GROUP BY MaGV
GO
--III.29 Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.
select A.MAGV, HOTEN 
from (
	select HOCKY, NAM, MAGV, rank() over (partition by HOCKY, NAM order by count(MAMH) desc) rank_SOMH from GIANGDAY
	group by HOCKY, NAM, MAGV
	) A inner join GIAOVIEN GV
on A.MAGV = GV.MAGV
where rank_SOMH = 1
GO
--III.30 Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất
select top 1 with ties MH.MAMH, TENMH
from MONHOC MH, KETQUATHI KQT
where(
	MH.MAMH = KQT.MAMH
	and LANTHI = 1
	and KQUA = 'Khong Dat'
	)
group by MH.MAMH, TENMH
order by count(*) desc
GO

--III.31 Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).
SELECT A.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI 
	WHERE LANTHI = 1 AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) A INNER JOIN HOCVIEN HV
ON A.MAHV = HV.MAHV
GO


--III.32 Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).
SELECT C.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI A
	WHERE NOT EXISTS (
		SELECT 1 
		FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) C INNER JOIN HOCVIEN HV
ON C.MAHV = HV.MAHV
GO

--III.33 Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi thứ 1).
SELECT A.MAHV, HO + ' ' + TEN AS HOTEN
FROM (
    SELECT MAHV
    FROM KETQUATHI
    WHERE LANTHI = 1 AND KQUA = 'Dat'
    GROUP BY MAHV
    HAVING COUNT(DISTINCT MAMH) = (SELECT COUNT(DISTINCT MAMH) FROM KETQUATHI WHERE LANTHI = 1)
) A
INNER JOIN HOCVIEN HV ON A.MAHV = HV.MAHV;
GO

--III.34 Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn đều đạt (chỉ xét lần thi sau cùng).
SELECT C.MAHV, HO + ' ' + TEN HOTEN FROM (
	SELECT MAHV, COUNT(KQUA) SODAT FROM KETQUATHI A
	WHERE NOT EXISTS (
		SELECT 1 FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Dat'
	GROUP BY MAHV
	INTERSECT
	SELECT MAHV, COUNT(MAMH) SOMH FROM KETQUATHI 
	WHERE LANTHI = 1
	GROUP BY MAHV
) C INNER JOIN HOCVIEN HV
ON C.MAHV = HV.MAHV
GO
--III.35 Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau
--		 cùng).
select MAMH, MAHV, HOTEN
from 
(
	select MAMH, HOCVIEN.MAHV, (HO+' '+TEN) HOTEN, rank() over (partition by MAMH order by max(DIEM) desc) as XEPHANG
	from HOCVIEN, KETQUATHI
	where(
		HOCVIEN.MAHV = KETQUATHI.MAHV
		and LANTHI = (select max(LANTHI) from KETQUATHI where MAHV = HOCVIEN.MAHV group by MAHV)
		)
	group by MAMH, HOCVIEN.MAHV, HO, TEN
)A
where XEPHANG = 1
GO

