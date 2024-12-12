import 'package:dio/dio.dart';
import 'group_model.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<List<Group>> getGroups() async {
    try {
      final response = await _dio.get('http://localhost:8080/groups');
      if (response.statusCode == 200) {
        List<Group> groups = (response.data as List)
            .map((groups) => Group.fromJson(groups))
            .toList();
        return groups;
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (e) {
      throw Exception('Error fetching groups: $e');
    }
  }

  Future<Group> getGroupByID(int index) async {
    try {
      final response = await _dio.get('http://localhost:8080/groups/${index}');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Group.fromJson(data);
      } else {
        throw Exception('Failed to load group');
      }
    } catch (e) {
      throw Exception('Error fetching group: $e');
    }
  }

  Future<void> deleteGroupByID(int index) async {
    try {
      final response = await _dio.delete('http://localhost:8080/groups/delete/${index}');
      if (response.statusCode == 204) {
        print('Group deleted!');
      } else {
        throw Exception('Failed to delete group');
      }
    } catch (e) {
      throw Exception('Error removing group: $e');
    }
  }

  Future<void> addGroup(Map<String, dynamic> newGroup) async {
    try {
      final response = await _dio.post('http://localhost:8080/groups/create', data: newGroup);
      if (response.statusCode == 200) {
        print('Group created!');
      } else {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      throw Exception('Error creating group: $e');
    }
  }

  Future<void> updateGroup(int index, Map<String, dynamic> updatedGroup) async {
    try {
      final response = await _dio.put('http://localhost:8080/groups/update/${index}', data: updatedGroup);
      if (response.statusCode == 200) {
        print('Group updated!');
      } else {
        throw Exception('Failed to update group');
      }
    } catch (e) {
      throw Exception('Error updating group: $e');
    }
  }

  Future<List<Group>> getFavourites() async {
    try {
      final response = await _dio.get('http://localhost:8080/groups/favourites');
      if (response.statusCode == 200) {
        List<Group> groups = (response.data as List)
            .map((groups) => Group.fromJson(groups))
            .toList();
        return groups;
      } else {
        throw Exception('Failed to load favourites');
      }
    } catch (e) {
      throw Exception('Error fetching favourites: $e');
    }
  }

  Future<List<Group>> getCartItems() async {
    try {
      final response = await _dio.get('http://localhost:8080/groups/cart');
      if (response.statusCode == 200) {
        List<Group> groups = (response.data as List)
            .map((groups) => Group.fromJson(groups))
            .toList();
        return groups;
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      throw Exception('Error fetching cart items: $e');
    }
  }
}