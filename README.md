# wsl_gui
基于wsl2和 Ubuntu 22.04 LTSC 的wsl图形窗口界面

编程语言：PowerBASIC 9

准备：
win10操作系统，
# 1.开始菜单->搜索Windows powershell，以管理员身份运行
# 2.选择wsl2
wsl --set-default-version 2
# 3.安装Linux内核更新包，直接点击下一步即可安装成功
地址：https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi


同一目录下创建 bak 文件夹，创建 Ubuntu_2204.1.7.0_x64 文件夹
bak 文件夹用来放置备份的tar文件。
Ubuntu_2204.1.7.0_x64 文件夹内容，如
![image](https://github.com/user-attachments/assets/180227fb-381c-4cb0-8358-2d62b718d72c)
从微软网站下载 **Ubuntu2204-221101.AppxBundle** (https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle)，
改后缀名为 .zip，双击打开（可用 winrar），拖拽出其中的 Ubuntu_2204.1.7.0_x64.appx 到 X:\wsl 文件夹，改后缀名为 .zip，
将 Ubuntu_2204.1.7.0_x64.appx.zip 中内容，解压到 X:\wsl\Ubuntu_2204.1.7.0_x64 文件夹
双击 ubuntu.exe，即可创建出虚拟机 Ubuntu 
