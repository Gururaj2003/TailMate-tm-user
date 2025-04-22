import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/pet.dart';
import '../models/service.dart';
import '../models/service_provider_model.dart';
import '../models/booking.dart';
import '../models/chat_history.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tailmate.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users Table
    await db.execute('''
      CREATE TABLE users (
        user_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        address TEXT,
        profile_image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Pets Table
    await db.execute('''
      CREATE TABLE pets (
        pet_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        breed TEXT,
        age INTEGER,
        gender TEXT,
        weight REAL,
        medical_history TEXT,
        profile_image_url TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
      )
    ''');

    // Service Providers Table
    await db.execute('''
      CREATE TABLE service_providers (
        provider_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        address TEXT,
        latitude REAL,
        longitude REAL,
        rating REAL DEFAULT 0.0,
        total_ratings INTEGER DEFAULT 0,
        profile_image_url TEXT,
        is_verified INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Services Table
    await db.execute('''
      CREATE TABLE services (
        service_id TEXT PRIMARY KEY,
        provider_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        duration INTEGER,
        category TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (provider_id) REFERENCES service_providers(provider_id) ON DELETE CASCADE
      )
    ''');

    // Bookings Table
    await db.execute('''
      CREATE TABLE bookings (
        booking_id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        provider_id TEXT NOT NULL,
        service_id TEXT NOT NULL,
        pet_id TEXT NOT NULL,
        booking_date TEXT NOT NULL,
        booking_time TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        payment_status TEXT DEFAULT 'pending',
        amount REAL NOT NULL,
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (provider_id) REFERENCES service_providers(provider_id),
        FOREIGN KEY (service_id) REFERENCES services(service_id),
        FOREIGN KEY (pet_id) REFERENCES pets(pet_id)
      )
    ''');

    // Chat History Table
    await db.execute('''
      CREATE TABLE chat_history (
        chat_id TEXT PRIMARY KEY,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        message TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users(user_id),
        FOREIGN KEY (receiver_id) REFERENCES service_providers(provider_id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_pets_user_id ON pets(user_id)');
    await db.execute('CREATE INDEX idx_services_provider_id ON services(provider_id)');
    await db.execute('CREATE INDEX idx_bookings_user_id ON bookings(user_id)');
    await db.execute('CREATE INDEX idx_bookings_provider_id ON bookings(provider_id)');
    await db.execute('CREATE INDEX idx_chat_history_sender_receiver ON chat_history(sender_id, receiver_id)');
  }

  // User Operations
  Future<String> insertUser(User user) async {
    final db = await database;
    user.userId = const Uuid().v4();
    await db.insert('users', user.toMap());
    return user.userId;
  }

  Future<User?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Pet Operations
  Future<String> insertPet(Pet pet) async {
    final db = await database;
    pet.petId = const Uuid().v4();
    await db.insert('pets', pet.toMap());
    return pet.petId;
  }

  Future<List<Pet>> getPetsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pets',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Pet.fromMap(maps[i]));
  }

  // Service Provider Operations
  Future<String> insertServiceProvider(ServiceProvider provider) async {
    final db = await database;
    provider.providerId = const Uuid().v4();
    await db.insert('service_providers', provider.toMap());
    return provider.providerId;
  }

  Future<List<ServiceProvider>> getServiceProviders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('service_providers');
    return List.generate(maps.length, (i) => ServiceProvider.fromMap(maps[i]));
  }

  // Booking Operations
  Future<String> insertBooking(Booking booking) async {
    final db = await database;
    booking.bookingId = const Uuid().v4();
    await db.insert('bookings', booking.toMap());
    return booking.bookingId;
  }

  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
  }

  // Chat Operations
  Future<String> insertChatMessage(ChatHistory chat) async {
    final db = await database;
    chat.chatId = const Uuid().v4();
    await db.insert('chat_history', chat.toMap());
    return chat.chatId;
  }

  Future<List<ChatHistory>> getChatHistory(String senderId, String receiverId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_history',
      where: '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
      whereArgs: [senderId, receiverId, receiverId, senderId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => ChatHistory.fromMap(maps[i]));
  }
} 