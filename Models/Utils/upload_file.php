
<?php
    session_start();
    if (!empty($_FILES['fichier']['tmp_name']) && is_uploaded_file($_FILES['fichier']['tmp_name'])) {

        $allowedExtensions = array("zip","gz","RData","csv", "tsv", "txt","tex","bib", "png", "pdf", "jpg", "jpeg");
        if (in_array(end(explode(".",$_FILES['fichier']['name'])), $allowedExtensions)){

            if(move_uploaded_file($_FILES['fichier']['tmp_name'],$_SERVER['DOCUMENT_ROOT']."files/shared/PatentsMining/".$_FILES['fichier']['name'])){
                echo "<p>Upload successful !</p>".PHP_EOL;
            }
            }
        else echo "Non supported format";
    }
    else echo "Upload error";
?>
