# Создание шифрованного LiveUSB.

Создание гибридного ISO образа Ubuntu 18.04 с шифрованной корневой ФС.

Порядок загрузки образа:

1. isolinux\syslinux загрузчик
2. kernel + initramfs
3. Ожидание подключения по ssh для разблокировки roofs
4. Разблокирование образа командой *cryptsetup-unlock* с вводом пароля
5. Загрузка основной системы из rootfs


Всё делалось на хост-системе Ubuntu 16.04

Необходиные пакеты:
```
sudo apt install initramfs-tools xorriso isolinux syslinux syslinux-common debootstrap cryptsetup squashfs-tools
```


## Описание файлов сборки
**0_bootstrap.sh** Создание базового образа

Заменить *passwd="mysecretpass"* на свой пароль. Используется как пароль root`а.

Добавить в *extra_sys=""* пакеты которые хотите установить.

Добавить модуль сетевой карты в 
```
echo "overlay
r8169
r8152
usbnet
" >> rootfs/etc/initramfs-tools/modules
```

**1_create_rootfs.sh** Сжатие образа в squashfs

**2_create_lusks.sh** Шифрование образа

Заменить *passwd="mysecretpasswd2"* на свой пароль. Используется для доступа к образу.

**3_make_iso.sh** Создание гибридного образа

Заменить настройки сети. Настраивает сеть в initramfs для ssh.

Если создать файл *media/interfaces* с описанием настройки сети, то они будут применены при разблокировании образа.
