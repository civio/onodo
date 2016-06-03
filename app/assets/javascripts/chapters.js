App.Dropzone.options.chapterDropzone = {
    autoProcessQueue: false,
    uploadMultiple: false,
    clickable: false,
    maxFiles: 1,
    acceptedFiles: "image/*",
    paramName: "chapter[image]",
    previewsContainer: ".media-left",
    previewTemplate: document.getElementById('dropzone-preview-template').innerHTML,

    init: function() {
        var theDropzone = this;

        this.element.querySelector("input[type=submit]").addEventListener("click", function(e) {
            e.preventDefault();
            e.stopPropagation();
            if (theDropzone.getQueuedFiles().length > 0) {
                theDropzone.processQueue();
            } else {
                e.srcElement.parentElement.submit();
            }
        });

        var mockFile = { name: "__mockfile__", size: 0 };
        var imageUrl = "#{@chapter.image_url(:medium)}";
        if (imageUrl) {
            this.emit("addedfile", mockFile);
            this.emit("thumbnail", mockFile, imageUrl);
            this.emit("complete", mockFile);
            this.files.push(mockFile);
        }

        this.on("addedfile", function() {
            var first_file = this.files[0];
            if (first_file.name == "__mockfile__" && first_file.size == 0) {
                this.removeFile(first_file);
            }
        });

        this.on("maxfilesexceeded", function() {
            var old_file = this.files[0];
            this.removeFile(old_file);
        });

        this.on("success", function(file, response) {
            window.location = response.location
        });
    }
}