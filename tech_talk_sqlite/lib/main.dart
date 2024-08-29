// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Primeiro adicionamos os packages 'SQFLite e Path ao projeto'
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Aqui nós criamos o db e armazenamos a referência
  final dataBase = openDatabase(

    // Passamos o path do db
    // Aqui usamos join como boa prática para garantir que o path está correto para todas as plataformas
    join(await getDatabasesPath(), 'dogs_database.db'),

    // Após o db ser criado, nós criamos então a tabela para armazenar nosso cachorros
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)');
    },
    // Setamos a versão, isso vai nos ajudar com upgrades e downgrades
    version: 1,
  );

  // Insert
  Future<void> insertDog(Dog dog) async {
    // Pegamos a referência do nosso banco
    final db = await dataBase;

    // Chamamos a função insert() para inserir o nosso dog no banco, c o método toMap, que converte o objeto Dog em Map
    await db.insert('dogs', dog.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('${dog.name} inserido');
  }

  // Criamos uma instancia do objeto Dog e inserimos no db
  var mocoto = Dog(id: 1, name: 'Mocotó', age: 5);
  await insertDog(mocoto);

  // Select
  Future<List<Dog>> listDogs() async {
    //Pegamos a referência do nosso banco
    final db = await dataBase;

    // Fazemos a query aqui na table dogs, passando uma lista de Map do tipo String, Object
    final List<Map<String, Object?>> dogMaps = await db.query('dogs');

    // Convertemos a lista de cada um dos campos dos cachorros em um lista do objeto Dog
    return [
      for (final {
            'id': id as int,
            'name': name as String,
            'age': age as int,
          } in dogMaps)
        Dog(id: id, name: name, age: age),
    ];
  }

  print(await listDogs());

  //Update
  Future<void> updateDog(Dog dog) async {
    //Pegamos a referência do nosso banco
    final db = await dataBase;

    //Chamamos o método update() para atualizar o registro no banco, passando a tabela
    await db.update(
      'dogs',
      dog.toMap(),
      // Utilizamos a cláusula where para garantir que estamos atualizando apenas aquele registro específico
      where: 'id = ?',
      // Passamos o id do dog como whereArg para prevenir SQL injection
      whereArgs: [dog.id],
    );
  }

  mocoto = Dog(id: mocoto.id, name: mocoto.name, age: mocoto.age * 7);

  await updateDog(mocoto);
  print(await listDogs());

  //Delete
  Future<void> deleteDog(int id) async {
    final db = await dataBase;

    //Chamamos o método delete() para remover o registro do banco, passando a tabela que queremos fazer a deleção
    await db.delete(
      'dogs',
      // Utilizamos a cláusula where para garantir que estamos deletando apenas aquele registro específico
      where: 'id = ?',
      // Passamos o id do dog como whereArg para prevenir SQL injection
      whereArgs: [id],
    );
  }

  await deleteDog(1);
  print(await listDogs());

}

class Dog {
  final int id;
  final String name;
  final int age;
  Dog({
    required this.id,
    required this.name,
    required this.age,
  });

  // Implementamos esse método para que fique mais fácil ver a info de cada dog
  @override
  String toString() => 'Dog(id: $id, name: $name, age: $age)';

  // Converte um objeto Dog em um Map. As chaves devem corresponder aos nomes das colunas no db
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
    };
  }
}
