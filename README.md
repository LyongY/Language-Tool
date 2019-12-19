# Language-Tool
本工具使用[XLNT](https://github.com/tfussell/xlnt)创建及解析xlsx, 版本:[xlnt v1.3.0](https://github.com/tfussell/xlnt/archive/v1.3.0.zip)

**注意: 使用此工具时,若提示打开Excel失败, 原因一般为Excel中同一单元格中格式不一(例如:同时含有数字和文本), 中性语言.xlsx请检查 IDS_GOOGLE_HELP6 至 IDS_GOOGLE_HELP13**

### 使用方式
- 左侧选择相应功能
- 在右侧拖入相应文件或者文件夹
- 点击 **Start**

### 基本功能
#### Excel 转 String
以 Excel 第一张 sheet 的第一列为 Key, 第一行为语言, 在目标文件夹下创建各[^语言文件夹], ID及翻译写入Localizable.strings

[^语言文件夹]: zh-Hans.lproj,en.lproj,fr.lproj等等

#### XML 转 String
XML格式要求:属性 *name* 作为本地化ID, 值作为本地化翻译

#### Excel 更新 Excel
遍历客户提供的 Excel 第一张 sheet 中所有值, 替换到中性语言 Excel 中相应位置, 最后保存更新后的中性 Excel 到输出目录

#### Excel 转 XML
以 Excel 第一张 sheet 的第一列为 Key, 第一行为语言, 在目标文件夹下创建各[^语言文件夹], Key 作为 name 属性, 写入strings.xml

[^语言文件夹]: zh-Hans,en,fr等等

#### 找出客户缺失语言
因客户定制语言原故, 提供语言给客户可能过了很久才定制完成, 期间中性语言也继续增加, 期间增加的翻译, 客户不能及时定制, 此功能可快速找出客户未翻译内容

#### CamView Plus语言
Excel 以中间空行为界, 空行以上按 **Excel 转 String** 转成 Localizable.strings 写入app目录, 空行以下按 **Excel 转 XML** 转成 strings.xml 写入 web 目录

#### 1024.png 生成各尺寸icon
以拖入图片, 生成所有所需尺寸小图标及 Contents.json, 写入输出目录


### 替换默认路径
对于常用且路径不经常变更的功能, 如: *CamView Plus语言, Excel 转 String*, 可于 UserData.swift 文件中自行替换

    注意: 文件夹路径最后不要加 "/"

#### 最后
本工具志于处理语言本地化中各项繁琐操作, 也可能存在各式各样的问题, 遇到问题可联系我或自行更改.

如果,,,,,,有人用的话
