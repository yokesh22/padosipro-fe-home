import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/assigned_lm.dart';

/// The user's Lifestyle Manager.
// TODO: load from the API once it exposes the assigned LM.
final assignedLmProvider = Provider<AssignedLm>((ref) => AssignedLm.pilot);
