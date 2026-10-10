import 'package:flutter/material.dart';

/// Ferramenta de inteligência artificial disponível no PixelAI.
///
/// O registo é partilhado pelo ecrã AI Tools (lista de ferramentas) e pelo
/// Editor, que adapta os controlos ao `id` da ferramenta selecionada.
class AiTool {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const AiTool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

/// Ferramentas apresentadas no ecrã AI Tools.
const List<AiTool> aiTools = [
  AiTool(
    id: 'backgroundRemover',
    name: 'Background Remover',
    description: 'Remove o fundo de uma fotografia.',
    icon: Icons.layers_outlined,
  ),
  AiTool(
    id: 'aiEnhance',
    name: 'AI Enhance',
    description: 'Melhora a nitidez, a qualidade e os detalhes.',
    icon: Icons.auto_awesome,
  ),
  AiTool(
    id: 'aiPortrait',
    name: 'AI Portrait',
    description: 'Aplica melhorias e estilos a retratos.',
    icon: Icons.face_retouching_natural_outlined,
  ),
  AiTool(
    id: 'objectRemover',
    name: 'Object Remover',
    description: 'Seleciona um objeto para o remover da imagem.',
    icon: Icons.highlight_alt,
  ),
  AiTool(
    id: 'backgroundGenerator',
    name: 'Background Generator',
    description: 'Substitui o fundo através de uma descrição.',
    icon: Icons.texture_outlined,
  ),
  AiTool(
    id: 'colorize',
    name: 'AI Colorize',
    description: 'Aplica cor a fotografias a preto e branco.',
    icon: Icons.palette_outlined,
  ),
  AiTool(
    id: 'restoration',
    name: 'Photo Restoration',
    description: 'Prepara uma fotografia antiga para restauro.',
    icon: Icons.auto_fix_high_outlined,
  ),
  AiTool(
    id: 'upscaler',
    name: 'AI Upscaler',
    description: 'Aumenta a resolução da fotografia.',
    icon: Icons.expand_outlined,
  ),
];
