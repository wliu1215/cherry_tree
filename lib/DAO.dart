import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';



class Note {
  int id;
  int parent;
  String title;
  String description;

  Note();
}

class NoteDao {

  Note fromMap(Map<String, dynamic> query) {
    Note note = Note();
    note.id = query["node_id"];
    note.title = query["name"];
    note.parent = query["father_id"];
    note.description = query["txt"];
    return note;
  }

  List<Note> fromList(List<Map<String,dynamic>> query) {
    List<Note> notes = List<Note>();
    for (Map map in query) {
      notes.add(fromMap(map));
    }
    return notes;
  }
}


class DatabaseProvider {
  static final _instance = DatabaseProvider._internal();
  static DatabaseProvider get = _instance;
  bool isInitialized = false;
  Database _db;

  DatabaseProvider._internal();

  Future<Database> db() async {
    if (!isInitialized) await _init();
    return _db;
  }

  Future _init() async {
    String path = join('/mnt/sdcard/Android/data/com.dropbox.android/files/u17068703/scratch', 'CT.ctb');
    _db = await openDatabase(path,  readOnly: true );
    print("Opened database");
  }
}


class NotesDatabaseRepository {
  final dao = NoteDao();

  DatabaseProvider databaseProvider;

  NotesDatabaseRepository(this.databaseProvider);


  Future<List<Note>> getNotes() async {
    final db = await databaseProvider.db();
    List<Map> maps = await db.rawQuery('SELECT father_id, children.node_id, name, txt FROM children, node where children.node_id = node.node_id order by father_id, sequence');
    return dao.fromList(maps);
  }
}
