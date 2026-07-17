
# IP
107.98.153.251

255.255.255.0
107.98.153.1

107.10.86.176
107.10.86.177 
# User

WinR > lusrmgr.msc
LocalUser

**User** Create
**Group** Add to Admin




## 1.Download toàn bộ file cài đặt về máy tính cursor tại link sau (SRV_USER/Abc!3579)
\\107.98.47.250\SRV Backup 2\cursorAi_setup\INSTALL_CURSOR_2026

(Nên "Add network location" hoặc "Map Network Drive" trước cho server này tí dùng cho backup file Bitlocker)

## 2.Join TN Domain (Follow guide Manual AD Join guide 1 phần tuy nhiên theo các bước như sau)
- Tạo LocalUser với quyền Admin
- Join TN domain với thông tin mới ShareAcc như sau

+ PCName: đặt theo format knoxid-D01, ví dụ HIEU-PHAM2-D01, TUAN-PHT-D01 (Search Start-> advance system)
+ Acc: TN\STN-ACEVPN
+ Pass:Samsung.com (share trong nhóm chat sau)
+ Domain: tn.corp.samsungelectronics.net

=> Khi có thông báo welcome là join PC với TN domain ok

Lưu ý: Tài khoản dùng chung, tuyệt đối ko public và share những người không liên quan, và không dùng tài khoản này để login PC

- Sau khi join xong sẽ báo successfuly
- WIn+L lock máy và login lại tài khoản LocalUser
- Sử dụng tài khoản LocalUser (Quyền Admin) Add TN\STN-ACEVPN và corp\knoxid vì dụ corp\hieu.pham2 vào nhóm Admin

Nếu có popup xác thực vui lòng nhập thông tin của SharedAcc

=> Xong xuôi hêt WIN+L để login vào tài khoản personal AD của bạn, ví dụ
corp\hieu.pham2/AD_pass (Từ giờ trở đi luôn dùng tài khoản AD cá nhân này login)

## 3. Bitlocker các ổ đĩa
- Bitlocker như guide ACE_VPN guide, tuy nhiên bạn cần 1 chỗ để lưu file bitlocker này, và do ko thể dùng ổ đĩa trong máy nền cần lưu lên server với thông tin sau

\\107.98.47.250\SRV Backup 2\cursorAi_setup\BACKUP_BITLOCKER (bạn có thể tạo folder knoxid của bạn)

-> Nếu có popup nhập user/pass thì điền: .\SRV_USER Pass: Abc!3579

srv_it
Abc!3579

-> Nếu vẫn không được, thì "Add network location" hoặc "Map Network Drive" trước cho server này

## 4. Setup VPN

Lưu ý: bạn phải down đủ hết file ở bước 1 về trước, vì rủi ro setup VPN lỗi bạn sẽ không có mạng để cop các file về nữa do bị ghi đè VPN IP

- Cài đặt security file theo các file
Security_File\old_file\intsallers\cert_installer.exe
Security_File\old_file\installer\total_installer.exe
Security_File\total_installer_latest.exe
Security\server.crt

-> Sau đó Follow theo guide: ACE-VPN Guide ppt (Lưu ý SingleID đã cài đặt xác thực vân tay Bio)


Lần 1 Khi tải thêm 3 gói cissco xong, nếu đợi lâu chưa có hiện icon và ISE -> tiến hành restart máy cho bước check ISE

-> Trong quá trình cài nếu bạn gặp lỗi ở bước ISE khi cài file (Fail to open downloader...)

-> Bạn hãy disconnect đi, tắt cisco đi, sau đó cài manual file: cisco-secure-client-win-4.3.4426.8192-isecompliance-predeploy-k9.msi tại folder: fix_fail

=> Mọi thứ sau khi setup thành công sẽ như guide, và bạn có thể vào các trang Cursor.com/ google.com...

=> Máy security lưu ý không vào các trang linh tinh, chúc các bạn thành công, nếu gặp khó khăn trao đổi tuan.pht (8F A-113)/vantinh.vu

Tài khoản cursor sẽ được active khi đủ số lượng các bạn join VPN thành công, và gửi lại link invitation sau ^^



# Log in
 {SingleID}@mx.forclouduse.samsung.com