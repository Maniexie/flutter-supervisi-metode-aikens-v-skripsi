import 'package:flutter/material.dart';

class ItemPenilaianDetail extends StatefulWidget {
  const ItemPenilaianDetail({super.key});

  @override
  State<ItemPenilaianDetail> createState() => _ItemPenilaianDetailState();
}

class _ItemPenilaianDetailState extends State<ItemPenilaianDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Item Penilaian DETAIL")));
  }
}
