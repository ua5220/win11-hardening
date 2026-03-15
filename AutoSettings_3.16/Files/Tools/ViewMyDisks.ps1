#   Сделал: westlife -- ru-board.com --
#   http://forum.ru-board.com/topic.cgi?forum=62&topic=30041&start=480#21

#   Скрипт получает всю важную информацию о дисках в системе, для использования результата в батнике
#   Намеренно исключаются диски без буквы, DVD и CD. Некоторые USB диски также не отобразятся, проблема в PS.
#   Главная Цель - обнаружить локальные и RAM диски. Остальное просто для красоты.

#   Создание таблицы для наполнения информацией по дискам
$TableDisks =@()

#   Получение информации по дискам из командлета Get-PhysicalDisk и далее из Get-Partition 
#   и добавление этих данных в таблицу $TableDisks
Get-PhysicalDisk | ForEach-Object {
 $_ |  Select-Object -Property DeviceId, MediaType, FriendlyName, BusType, SpindleSpeed | Out-Null
 $n=$_.DeviceId
 $mt=$_.MediaType
 $fn=$_.FriendlyName
 $b=$_.BusType
 if ($_.SpindleSpeed -eq '0' -and "$b" -eq 'USB') {$mt='Flash'}
 Get-Partition -DiskNumber $n -ErrorAction SilentlyContinue | ForEach-Object {
  $_ | Select-Object -Property  DriveLetter, Size | Out-Null
  $d=$_.DriveLetter
  $s=$_.Size
  if ("$mt" -eq 'Unspecified' -and "$b" -eq 'Unknown') {$mt='RAM'; $b='RAM'}
  if ("$mt" -eq 'Unspecified' -and "$b" -eq 'RAID') {$mt='HDD'}
  if ("$mt" -eq 'Unspecified' -and "$b" -ne 'Unknown' -and "$b" -ne 'RAID') {$mt='Virtual'}
  $TableDisks += New-Object PsObject -Property @{Number="$n"; Drive="$d"+':'; Size="$s"; MediaType="$mt"; Name="$fn"; Bus="$b"}
 }
}

#   Получение дополнительных данных о дисках из WMI через командлет Get-WmiObject
#   И добавление в таблицу $TableDisks дополнительной инфы, к уже добавленным данным о дисках, либо добавление новых дисков
Get-WmiObject -Class win32_logicaldisk -Filter "DriveType=0 or DriveType=2 or DriveType=3 or DriveType=6" | ForEach-Object {
 $_ | Select-Object -Property DeviceID, VolumeName, Size, FileSystem, MediaType, DriveType | Out-Null
 $id=$_.DeviceID
 $v=$_.VolumeName
 $f=$_.FileSystem
 $s=$_.Size
 if ($_.MediaType -eq 12) {$mt='RAM'} elseif ($_.MediaType -eq $null) {$mt='Flash'} else {$mt=$_.MediaType}
 if ($_.DriveType -eq 2) {$b='USB'} else {$b='RAM'}
 $x = $TableDisks | Where-Object -Filter {$_.Drive -like "$id"}
 if ($x -eq $null)
 { 
     $TableDisks += New-Object PsObject -Property @{Drive="$id"; Size="$s"; MediaType="$mt"; Bus="$b"; VolumeName="$v"; FileSystem="$f"}
 }
 else 
 { 
     $TableDisks | Where-Object -Filter {$_.Drive -like "$id"} | Add-Member -MemberType NoteProperty -name VolumeName -Value "$v" -Force
     $TableDisks | Where-Object -Filter {$_.Drive -like "$id"} | Add-Member -MemberType NoteProperty -name FileSystem -Value "$f" -Force
 }
}

#   Вывод данных всей таблицы $TableDisks в %Temp%\AllDisks.log, с изменением названий столбцов,
#   переводом размеров байт в гигабайты, и добавлением символа "|" для возможности сортировки в батнике
$TableDisks | Where-Object -Filter {$_.Drive -match "[C-Z]"} | Sort-Object -Property Drive, Bus | Format-Table -Property `
  @{name="Диск"; e={$_.Drive+'|'}}, `
  @{name="Размер"; e={"{0:F2}" -f ($_.Size / 1Gb )+' Гб|'}}, `
  @{name="Название"; e={$_.VolumeName+'|'}}, `
  @{name="Ф/с"; e={$_.FileSystem+'|'}}, `
  @{name="Тип"; e={$_.MediaType+'|'}}, `
  @{name="Шина"; e={$_.Bus+'|'}}, `
  @{name="Устройство"; e={$_.Name+'|'}} -AutoSize | Out-File -encoding  UTF8 "$Env:temp\AllDisks.log"




