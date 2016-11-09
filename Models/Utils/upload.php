

<h1>Upload</h1>

<p>Allowed extensions : zip,gz,RData,csv,tsv,txt,tex,bib,png,pdf,jpg,jpeg</p>

<p>free space on disk :

<?php
echo exec("df -h | grep \"/dev/\" | grep -v \"/var\" | awk -F\" \" '{print $4}'");
?>

</p>

<form class="forms" action="upload_file.php" method="post" enctype="multipart/form-data">
            <input type="file" name="fichier" id="fichier"/><br/><br/>
            <input type="submit" value="Upload" id="uploadButton"/><br/><br/>
</form>

<a href=".">Data Directory</a>

<!--<iframe id="uploadOk" name="uploadOk" src="#"></iframe>-->
