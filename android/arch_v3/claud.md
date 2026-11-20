Có, việc flash chắc chắn đã hoàn tất. Lệnh nối bằng `&&` nên `reboot` chỉ chạy khi `dd` và `sync` đều thành công. Hơn nữa, nếu image bị ghi dở thì máy đã không boot lên được, vậy mà máy đang trả lời ping. Vấn đề nằm ở chỗ khác: **kernel mới đã boot, nhưng phần userspace của chúng ta không lên**.

## Những gì tôi thấy từ xa
- **Ping ổn định 60/60, không rớt gói nào**, nên không phải bootloop. Kernel đang chạy bình thường và driver mạng hoạt động.
- **Không có cổng nào mở**, kể cả 22 (sshd) và 5555 (adb TCP).
- **Tailscale `lg-server` offline**, nghĩa là chroot và dinit chưa chạy.

## Hai khả năng
1. **Magisk không chạy được với kernel mới**, nên `service.d/00_init.sh` không được gọi, adb TCP không bật và chroot không khởi động. IP `.69` khi đó có thể do Android tự nhận qua DHCP, nếu router đang giữ cố định IP cho MAC này. Tôi thấy khả năng này cao hơn.
2. **`00_init.sh` có chạy nhưng bị kẹt** ngay sau bước gán IP. Khả năng này thấp: nếu script đã chạy tới đó thì adbd lẽ ra đã lên ngay sau.

Từ xa tôi không phân biệt được hai trường hợp này, nên cần bạn thao tác tận tay.

## Khi bạn ở cạnh máy
1. **Nhìn màn hình:**
   - Nếu thấy màn hình khoá hoặc giao diện Android bình thường, thì framework vẫn chạy, tức lệnh `stop` trong `00_init.sh` chưa hề chạy. Đó là trường hợp 1.
   - Nếu màn hình đen hoặc chỉ có logo, thì script đã chạy tới `stop`. Đó là trường hợp 2.
2. **Lấy log để tôi tìm nguyên nhân** (chọn một trong hai cách):
   - **Cách nhanh:** rút hub, cắm phone thẳng vào máy home qua USB rồi chạy `adb devices`. Nếu adb qua USB vào được (khả năng cao, vì bản build userdebug), tôi sẽ đọc log và sửa trực tiếp mà không cần flash lại.
   - **Nếu adb USB không được:** quay về kernel cũ:
     1. Tắt máy, giữ Vol‑Down rồi cắm USB vào máy home để vào fastboot.
     2. Chạy `fastboot flash boot_b ~/Repos/g8-kernel/backup/boot_b.img`.
     3. Chạy `fastboot reboot`.
     
     Máy sẽ về trạng thái trước khi flash, sau đó tôi phân tích offline.
3. Khi đã vào được adb USB, tôi cần xem các log sau:
   ```sh
   adb shell su -c 'cat /data/local/tmp/arch-init.log | tail; ls /data/adb/magisk; magisk -c'
   adb shell 'dmesg | grep -iE "magisk|selinux|avc" | tail -30'
   ```

Bạn có thể có mặt cạnh máy trong bao lâu nữa? Khi cắm USB xong, báo tôi để tôi tiếp tục.



Đúng, patch lại được. Nhưng nhiều khả năng nó không sửa được lỗi lần này. Image vừa flash được đóng gói từ chính `boot_b.img` đã patch Magisk, và tôi đã kiểm tra **ramdisk giống hệt bản gốc (`RAMDISK_SAME`)**. Phần Magisk vẫn còn nguyên trong image. Thứ duy nhất thay đổi là kernel, nên nếu Magisk không chạy thì nguyên nhân nằm ở chỗ Magisk tương tác với kernel mới, không phải do mất bản patch.

## Nếu vẫn muốn patch lại
**Cách 1: patch trên phone qua `adb shell`** (adb USB, không cần root):
```sh
adb push boot_b-v2-sgtso-docker.img /data/local/tmp/
# lấy Magisk.apk đúng phiên bản đang dùng, giải nén lib/arm64-v8a/*.so và assets/
adb shell 'cd /data/local/tmp/magisk && sh boot_patch.sh ../boot_b-v2-sgtso-docker.img'
adb pull /data/local/tmp/magisk/new-boot.img
fastboot flash boot_b new-boot.img
```
Nếu image đã có Magisk sẵn, `boot_patch.sh` sẽ tự khôi phục ramdisk gốc từ backup bên trong rồi patch lại, nên patch chồng lên vẫn an toàn.

**Cách 2: dùng app Magisk.** Cách này cần giao diện Android, không hợp với máy headless khi framework đã bị `stop`.

**Lưu ý:** đừng lấy `boot_b.img` trong backup làm "bản stock". Bản đó đã patch Magisk từ trước rồi. Nếu cần boot.img stock thật, phải lấy từ file zip của bản ROM LineageOS unofficial.

## Nên làm theo thứ tự này
1. **Cắm USB vào máy home và thử `adb devices` trước.** Nếu vào được, tôi sẽ đọc `dmesg` và log Magisk để biết chính xác lỗi gì. Nếu do thiếu hay xung đột một config kernel, tôi build lại khoảng 2 phút là xong.
2. **Khôi phục tạm** bằng `fastboot flash boot_b ~/Repos/g8-kernel/backup/boot_b.img` để server chạy lại, rồi phân tích sau.
3. **Từ lần sau, test bằng `fastboot boot <img>`** trước khi `dd` vào flash. Lệnh này chỉ boot một lần, reboot là tự quay về kernel cũ, nên lỗi kiểu này không làm mất server nữa.

Bạn có muốn tôi chuẩn bị sẵn bộ file `boot_patch.sh` và magiskboot trên máy home (đúng phiên bản Magisk trong backup) để khi cần là dùng được ngay không?