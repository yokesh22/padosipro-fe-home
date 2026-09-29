import 'package:flutter/material.dart';

class ServiceCategory {
  const ServiceCategory({
    required this.label,
    required this.description,
    required this.icon,
    required this.subTypes,
    this.isSoon = false,
  });

  final String label;
  final String description;
  final IconData icon;
  final List<String> subTypes;
  final bool isSoon;
}

/// Service categories shown on Home (first [homeChipCount] as chips) and
/// on the All services screen.
abstract final class ServiceCatalog {
  static const homeChipCount = 6;

  static const categories = <ServiceCategory>[
    ServiceCategory(
      label: 'Errands & Daily Tasks',
      description: 'Bills, banks, documents, government work',
      icon: Icons.fact_check_outlined,
      subTypes: ['Bill Payments', 'Bank Work', 'Documents', 'Govt. Offices'],
    ),
    ServiceCategory(
      label: 'Home Services',
      description: 'AC, plumbing, electrical, cleaning, repairs',
      icon: Icons.home_outlined,
      subTypes: ['AC & Appliances', 'Plumbing', 'Electrical', 'Deep Cleaning'],
    ),
    ServiceCategory(
      label: 'Travel & Tourism',
      description: 'Flights, hotels, visas, transfers, itineraries',
      icon: Icons.place_outlined,
      subTypes: [
        'Book Travel',
        'On-Trip Support',
        'Documents & Visa',
        'Local Transport',
      ],
    ),
    ServiceCategory(
      label: 'Health & Medical',
      description: 'Doctor visits, pharmacy, labs, physio',
      icon: Icons.favorite_border,
      subTypes: ['Doctor Visit', 'Medicines', 'Lab Tests', 'Physiotherapy'],
    ),
    ServiceCategory(
      label: 'Senior Care',
      description: 'Check-ins, medicines, vitals, companionship',
      icon: Icons.people_outline,
      subTypes: [
        'Daily Check-ins',
        'Medicine Reminders',
        'Vitals Tracking',
        'Companionship',
      ],
    ),
    ServiceCategory(
      label: 'Events & Management',
      description: 'Weddings, décor, catering, photography',
      icon: Icons.calendar_today_outlined,
      subTypes: ['Plan an Event', 'Décor', 'Catering', 'Photography'],
    ),
    ServiceCategory(
      label: 'Workforce Management',
      description: 'Maids, cooks, drivers, nannies, payroll',
      icon: Icons.work_outline,
      subTypes: ['Hire Help', 'Replacement', 'Verification', 'Payroll'],
    ),
    ServiceCategory(
      label: 'Digital & Tech Help',
      description: 'WiFi, CCTV, smart locks, device repair',
      icon: Icons.wifi,
      subTypes: [
        'WiFi & Internet',
        'CCTV Setup',
        'Smart Locks',
        'Device Repair',
      ],
    ),
    ServiceCategory(
      label: 'Relocation Services',
      description: 'Packers, movers, handover, paperwork',
      icon: Icons.local_shipping_outlined,
      subTypes: ['Packers & Movers', 'House Hunting', 'Handover', 'Paperwork'],
    ),
    ServiceCategory(
      label: 'NutriFix',
      description: 'Groceries, food delivery, diet plans, meal prep',
      icon: Icons.shopping_bag_outlined,
      subTypes: ['Groceries', 'Food Delivery', 'Diet Plans', 'Meal Prep'],
      isSoon: true,
    ),
    ServiceCategory(
      label: 'Fashion & Styling',
      description: 'Salon at home, tailoring, styling, gifting',
      icon: Icons.content_cut,
      subTypes: ['Salon at Home', 'Tailoring', 'Personal Styling', 'Gifting'],
      isSoon: true,
    ),
    ServiceCategory(
      label: 'Religious & Cultural',
      description: 'Pujas, priests, festivals, temple visits',
      icon: Icons.local_fire_department_outlined,
      subTypes: [
        'Book a Puja',
        'Find a Priest',
        'Festival Prep',
        'Temple Visits',
      ],
      isSoon: true,
    ),
  ];
}
