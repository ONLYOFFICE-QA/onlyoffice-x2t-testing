# Testing x2t

Is project for testing main conversion lib in onlyoffice documentserver

## How it work

X2t utility need 12 libs for work.
They are placed in documentserver
`/var/www/onlyoffice/documentserver/server/FileConverter/bin/`.
Easy way to take it - use docker-compose from this project.
After it, you need to place all lib's to `/usr/lib`
in your server, and then start work with x2t.

Example for x2t work:

 `x2t file_for_convert.docx resulting_file.ods folder_with_fonts`

`file_for_convert.docx` -
filename (or filepath)
for file for convertion. Right extname is important

`resulting_file.ods` -
filename (or filepath) for resulting
file. Right extname is important

`folder_with_fonts` - path to folder with fonts. Optional parameter.

Example for x2t work with xml parameter:

You can use xml file with parameters instead of
parameners in command line. For it,
create file like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<TaskQueueDataConvert xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
 <m_sKey>conv_Khirz6zTPdar34_pdf</m_sKey>
 <m_sFileFrom>/share/CreateImage.docx</m_sFileFrom>
 <m_sFileTo>/share/CreateImage.pdf</m_sFileTo>
 <m_nFormatTo>513</m_nFormatTo>
 <m_bIsPDFA xsi:nil="true" />
 <m_nCsvTxtEncoding>46</m_nCsvTxtEncoding>
 <m_nCsvDelimiter>4</m_nCsvDelimiter>
 <m_nCsvDelimiterChar xsi:nil="true" />
 <m_bPaid xsi:nil="true" />
 <m_bEmbeddedFonts>false</m_bEmbeddedFonts>
 <m_bFromChanges xsi:nil="true" />
 <m_sFontDir/>
 <m_sJsonParams xsi:nil="true" />
 <m_nLcid xsi:nil="true" />
 <m_oTimestamp>2020-09-30T11:14:00.207Z</m_oTimestamp>
 <m_bIsNoBase64>true</m_bIsNoBase64>
 <m_oInputLimits>
  <m_oInputLimit type="docx;dotx;docm;dotm">
   <m_oZip uncompressed="52428800" template="*."/>
  </m_oInputLimit>
  <m_oInputLimit type="xlsx;xltx;xlsm;xltm">
   <m_oZip uncompressed="4294967290" template="*.xml"/>
  </m_oInputLimit>
  <m_oInputLimit type="pptx;ppsx;potx;pptm;ppsm;potm">
   <m_oZip uncompressed="52428800" template="*.xml"/>
  </m_oInputLimit>
 </m_oInputLimits>
</TaskQueueDataConvert>
```

`m_sFileFrom` - filename (or filepath) for file for convertion.
 Right extname is important

`m_sFileTo` -  filename (or filepath) for resulting file. Right extname is important

`m_nFormatTo` - digital code for formal (513 - pdf)

X2t need more libs for convertion to pdf. All necessary
libs in described in `DoctRenderer.config`,
but you can use x2t inside of documentserver for easy setup

## Getting Started

### Running tests

Change **dockerfile** and **docker-compose** file.

1. Change image in .env.

2. Set 3 environment variables in dockerfile:

    **S3_KEY** - is a public s3 key for getting files

   **S3_PRIVATE_KEY** - is a private s3 key for getting files

   **PALLADIUM_TOKEN** - is a palladium token for writing results.

Then, run documentserver docker-compose for getting all libs

``docker-compose up documentserver``

And then, you can run tests

``docker-compose up -d x2t-testing``

## Convert Utility

Libs in this project can be used separately of tests like utility for conversion.

### For Start

1. Change image in ``.env.``
2. Run documentserver docker-compose for getting all libs with the
command: ``docker-compose up documentserver``
3. Change ``configure.json``
4. Run conversion

File **configure.json** contain all settings for it.

Example:

```bash
{
  "convert_from": "/tmp/folders_with_files/",
  "custom_folder": "/tmp/path_to_source_files/",
  "convert_to": "/tmp/results/",
  "custom_format": "docx",
  "conversion_formats": {
    "doc": "docx",
    "ppt": "pptx",
    "xls": "xlsx",
    "odp": "pptx",
    "rtf": "docx"
  },
  "x2t_path": "tmp/x2t",
  "font_path": "tmp/fonts"
}
```

**convert_from** -  path to folders with documents before conversion,
the folder names must match the file extension(if the file extension
in the folder is ".doc", then the folder name must be "doc"), used to
convert from an array of extensions with the **rake convert[arr]** command

**custom_folder** - the path to a separate folder with the source files to
convert using the **rake convert[cstm]** command

**custom_format** - files from **custom_folder** will be converted to this
format, to convert using the **rake convert[cstm]** command

**convert_to** - is a folder for results.

**conversion_formats** - an array of extensions to convert

**x2t_path** - path to x2t file.

**font_path**- path to fonts folder

## Сonversion commands

 ``rake convert[arr]``- Conversion from an array of extensions specified
 in**configure.json/conversion_formats**.

 ``rake convert[cstm]`` - Conversion from a separate folder with files.

## Checking ooxmlparser

To enable the ooxmlparser check, pass ``true`` as the second argument to the command.
Example:
``rake convert[arr,true]``

## Troubleshooting

* Error `Couldn't create temp folder`

  You need to execute x2t with `sudo`, or add more accesses to x2t

* Infinity conversion

  There in timeout for conversion in documentserver - 5 minutes.
If conversion of some files os hold more time - document will
not be saved. It is bad, but sometimes it happens.
Need to create bug if this behavior is a new for current file.

* Errors in console during conversion

  It is not bad, see resulting file

* Resulting file is not created/file with zero size

  You need to create new bug for Elena Subbotina. Example of bug - 39541
