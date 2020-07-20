import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shell/shell.dart';

class ProjectStatus {
  String path;
  bool status;
  bool wait = false;

  ProjectStatus(this.path, this.status);
}

class Projects extends StatefulWidget {
  @override
  _ProjectsState createState() => _ProjectsState();
}

class _ProjectsState extends State<Projects> {
  final projects = new Map<String, ProjectStatus>();

  static const NAME_KEY = 'com.docker.compose.project';
  static const DIR_KEY = 'com.docker.compose.project.working_dir';

  // Add project to list.
  void _appendProject(String name, String path, bool status) {
    // Projects not in list or it has disabled status, we can get only docker containers, not compose items.
    if (!projects.containsKey(name) || (projects.containsKey(name) && !projects[name].status && status)) {
      setState(() {
        projects.addEntries([MapEntry<String, ProjectStatus>(name, new ProjectStatus(path, status))]);
      });
    }
  }

  // Parse docker inspect data.
  void _parseItem(String value) {
    var json = jsonDecode(value);
    if (json.length > 0) {
      var labels = Map<String, String>.from(json[0]['Config']['Labels']);
      bool status = json[0]['State']['Running'];
      if (labels.containsKey(NAME_KEY) && labels.containsKey(DIR_KEY)) {
        _appendProject(labels[NAME_KEY], labels[DIR_KEY], status);
      }
    }
  }

  // Refresh list of projects.
  void _refresh() async {
    projects.clear();
    var shell = new Shell();
    var out = await shell.startAndReadAsString('docker', ['ps', '--all', '-q']);
    var ids = out.split("\n");
    for (var id in ids) {
      if (id.isNotEmpty) {
        shell.startAndReadAsString('docker', ['inspect', id]).then(_parseItem);
      }
    }
  }

  // Start project.
  void startProject(String name) {
    var shell = new Shell(workingDirectory: projects[name].path);
    projects[name].wait = true;
    setState(() {
      projects;
    });
    shell.startAndReadAsString('docker-compose', ['start']).then((String output) => _refresh()).catchError(print);
  }

  // Stop project.
  void stopProject(String name) {
    var shell = new Shell(workingDirectory: projects[name].path);
    projects[name].wait = true;
    setState(() {
      projects;
    });
    shell.startAndReadAsString('docker-compose', ['stop']).then((String output) => _refresh()).catchError(print);
  }

  @override
  void initState() {
    this._refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        var name = projects.keys.elementAt(index);
        var project = projects[name];
        return new ListTile(
          contentPadding: EdgeInsets.only(left: 15.0, right: 30.0),
          title: new Text(
            name,
            style: new TextStyle(
                fontSize: 32.0,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w300,
                fontFamily: "Roboto"),
          ),
          subtitle: new Text(
            project.path,
            style: new TextStyle(
                fontSize: 18.0,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w200,
                fontFamily: "Roboto Mono"),
          ),
          trailing: _buildCheckbox(project),
          enabled: !project.wait,
          onTap: () => {project.status ? stopProject(name) : startProject(name)},
        );
      },
    );
  }

  _buildCheckbox(ProjectStatus project) {
    return project.wait
        ? new SizedBox(width: 20, height: 20, child: new CircularProgressIndicator(strokeWidth: 2.0))
        : new Icon(project.status ? Icons.check_box : Icons.check_box_outline_blank, color: Colors.blue);
  }
}
