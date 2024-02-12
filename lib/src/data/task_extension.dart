part of '../easy_downloader_base.dart';

/// helper for [DownloadTask]
/// [start] start task
/// [pause] pause task
/// [continueDownload] continue task
/// [cancel] cancel task
/// [delete] delete task
/// [retry] retry task
/// [updateBlock] update block
/// [updateLocalPath] updates the download path (e.g. to fix invalid path
///   after app restarts since iOS changes application documents
///   directory's absolute path at every app launch)
/// [delete] delete task from database
extension TaskExtension on DownloadTask {
  ///start task
  void start() {
    //ignore: lines_longer_than_80_chars
    final task = EasyDownloader._localeStorage.getDownloadTaskSync(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    assert(
        task?.status != DownloadStatus.downloading &&
            task?.blocks.isEmpty == true,
        "EasyDownloader: task is already downloading");
    EasyDownloader._downloadManager.downloadTask(this);
  }

  ///pause task
  Future<void> pause() async {
    //ignore: lines_longer_than_80_chars
    final task =
        await EasyDownloader._localeStorage.getDownloadTask(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    assert(task?.status == DownloadStatus.downloading,
        "EasyDownloader: task is not downloading");
    await EasyDownloader._downloadManager.pauseTask(task!);
  }

  ///continue task
  Future<void> continueDownload() async {
    //ignore: lines_longer_than_80_chars
    final task =
        await EasyDownloader._localeStorage.getDownloadTask(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    //ignore: lines_longer_than_80_chars
    assert(
      task!.status == DownloadStatus.paused,
      'EasyDownloader: task status must be paused',
    );
    await EasyDownloader._downloadManager.continueTask(task!);
  }

  ///cancel task
  void cancel() {
    //todo
  }

  ///update task
  DownloadTask updateSync() {
    final task = EasyDownloader._localeStorage.getDownloadTaskSync(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    return task!;
  }

  ///update task
  Future<DownloadTask> update() async {
    //ignore: lines_longer_than_80_chars
    final task =
        await EasyDownloader._localeStorage.getDownloadTask(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    return task!;
  }

  ///add listener
  void addListener(DownloadTaskListener listener) {
    EasyDownloader._localeStorage.addListener(listener, downloadId);
  }

  ///remove listener
  void removeListener(DownloadTaskListener listener) {
    EasyDownloader._localeStorage.removeListener(listener);
  }

  ///add speed listener
  void addSpeedListener(SpeedListener listener) {
    EasyDownloader._speedManager.addListener(listener, downloadId);
  }

  ///remove speed listener
  void removeSpeedListener(SpeedListener listener) {
    EasyDownloader._speedManager.removeListener(listener);
  }

  ///add task to queue
  Future addInQueue() async {
    var task = await EasyDownloader._localeStorage.getDownloadTask(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    assert(
        task?.status == DownloadStatus.queuing ||
            task?.status == DownloadStatus.none,
        "EasyDownloader: task is already queuing");
    task = task!.copyWith(status: DownloadStatus.queuing, inQueue: true);
    await EasyDownloader._localeStorage.setDownloadTask(task);
    EasyDownloader._runner.addTask(task);
  }

  ///update the file path the task downloads to
  Future<DownloadTask> updateLocalPath(String newPath) async {
    var task = await EasyDownloader._localeStorage.getDownloadTask(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    task = task!.copyWith(path: newPath);
    await EasyDownloader._localeStorage.setDownloadTask(task);
    return task;
  }

  ///delete task from database
  void delete() async {
    var task = await EasyDownloader._localeStorage.getDownloadTask(downloadId);
    assert(task != null, 'EasyDownloader: task must not be null');
    await EasyDownloader._localeStorage.deleteDownloadTask(downloadId);
  }
}

extension IdExtension on Id {
  ///get download task
  Future<DownloadTask?> downloadTask() async {
    return EasyDownloader._localeStorage.getDownloadTask(this);
  }
}
