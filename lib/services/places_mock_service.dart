import '../models/itinerary.dart';

/// Massa de pontos de interesse mock, agrupados por cidade/bairro.
/// Usados quando não há API disponível ou como fallback offline.
const List<Place> _saoPauloPlaces = [
  Place(
    id: 'sp-001',
    name: 'Mercadão Municipal',
    description: 'Mercado histórico com gastronomia típica e frutas exóticas.',
    category: PlaceCategory.restaurant,
    latitude: -23.5415,
    longitude: -46.6289,
    address: 'R. da Cantareira, 306 - Centro',
    rating: 4.7,
  ),
  Place(
    id: 'sp-002',
    name: 'Pinacoteca do Estado',
    description: 'Museu de arte com um dos mais importantes acervos do Brasil.',
    category: PlaceCategory.museum,
    latitude: -23.5346,
    longitude: -46.6321,
    address: 'Praça da Luz, 2 - Luz',
    rating: 4.8,
  ),
  Place(
    id: 'sp-003',
    name: 'Parque Ibirapuera',
    description: 'Principal parque urbano de São Paulo, ideal para caminhadas.',
    category: PlaceCategory.park,
    latitude: -23.5874,
    longitude: -46.6576,
    address: 'Av. Pedro Álvares Cabral - Vila Mariana',
    rating: 4.8,
  ),
  Place(
    id: 'sp-004',
    name: 'Bar do Espeto',
    description: 'Clássico boteco paulistano com petiscos tradicionais.',
    category: PlaceCategory.bar,
    latitude: -23.5600,
    longitude: -46.6610,
    address: 'R. Augusta, 2325 - Jardins',
    rating: 4.2,
  ),
  Place(
    id: 'sp-005',
    name: 'Catedral da Sé',
    description: 'Icônica catedral neogótica no coração de São Paulo.',
    category: PlaceCategory.church,
    latitude: -23.5503,
    longitude: -46.6339,
    address: 'Praça da Sé, s/n - Sé',
    rating: 4.6,
  ),
  Place(
    id: 'sp-006',
    name: 'Feira da Liberdade',
    description: 'Maior feira oriental fora do Japão, com gastronomia e cultura.',
    category: PlaceCategory.shopping,
    latitude: -23.5588,
    longitude: -46.6328,
    address: 'Praça da Liberdade - Liberdade',
    rating: 4.5,
  ),
];

const List<Place> _recifePlaces = [
  Place(
    id: 're-001',
    name: 'Marco Zero',
    description: 'Ponto histórico no centro do Recife Antigo com shows e feiras.',
    category: PlaceCategory.tourist,
    latitude: -8.0630,
    longitude: -34.8711,
    address: 'Praça Rio Branco - Recife Antigo',
    rating: 4.7,
  ),
  Place(
    id: 're-002',
    name: 'Praia de Boa Viagem',
    description: 'Uma das praias mais famosas do Nordeste, com piscinas naturais.',
    category: PlaceCategory.beach,
    latitude: -8.1197,
    longitude: -34.8995,
    address: 'Av. Boa Viagem - Boa Viagem',
    rating: 4.5,
  ),
  Place(
    id: 're-003',
    name: 'Instituto Ricardo Brennand',
    description: 'Complexo cultural com castelo medieval, museu e jardins.',
    category: PlaceCategory.museum,
    latitude: -8.0539,
    longitude: -34.9523,
    address: 'Alameda Antônio Brennand - Várzea',
    rating: 4.9,
  ),
  Place(
    id: 're-004',
    name: 'Restaurante Leite',
    description: 'Restaurante mais antigo do Brasil em funcionamento contínuo.',
    category: PlaceCategory.restaurant,
    latitude: -8.0597,
    longitude: -34.8801,
    address: 'Praça Joaquim Nabuco, 147 - Santo Antônio',
    rating: 4.4,
  ),
  Place(
    id: 're-005',
    name: 'Parque 13 de Maio',
    description: 'Parque histórico no centro da cidade, perfeito para descanso.',
    category: PlaceCategory.park,
    latitude: -8.0574,
    longitude: -34.8838,
    address: 'R. do Hospício - Boa Vista',
    rating: 4.1,
  ),
  Place(
    id: 're-006',
    name: 'Spazio Libero',
    description: 'Bar e restaurante com vista para o rio e música ao vivo.',
    category: PlaceCategory.bar,
    latitude: -8.0645,
    longitude: -34.8718,
    address: 'Av. Marquês de Olinda - Bairro do Recife',
    rating: 4.3,
  ),
];

const List<Place> _rioDePlacas = [
  Place(
    id: 'rj-001',
    name: 'Cristo Redentor',
    description: 'Uma das sete maravilhas do mundo moderno, no topo do Corcovado.',
    category: PlaceCategory.tourist,
    latitude: -22.9519,
    longitude: -43.2105,
    address: 'Parque Nacional da Tijuca - Alto da Boa Vista',
    rating: 4.9,
  ),
  Place(
    id: 'rj-002',
    name: 'Praia de Copacabana',
    description: 'A praia mais famosa do mundo, repleta de cultura carioca.',
    category: PlaceCategory.beach,
    latitude: -22.9711,
    longitude: -43.1823,
    address: 'Av. Atlântica - Copacabana',
    rating: 4.7,
  ),
  Place(
    id: 'rj-003',
    name: 'Museu Nacional de Belas Artes',
    description: 'Principal museu de artes visuais do Brasil.',
    category: PlaceCategory.museum,
    latitude: -22.9099,
    longitude: -43.1759,
    address: 'Av. Rio Branco, 199 - Centro',
    rating: 4.6,
  ),
  Place(
    id: 'rj-004',
    name: 'Restaurante Aprazível',
    description: 'Gastronomia brasileira contemporânea com vista para Santa Teresa.',
    category: PlaceCategory.restaurant,
    latitude: -22.9200,
    longitude: -43.1831,
    address: 'R. Aprazível, 62 - Santa Teresa',
    rating: 4.8,
  ),
  Place(
    id: 'rj-005',
    name: 'Jardim Botânico',
    description: 'Espaço verde de 137 hectares com mais de 6500 espécies.',
    category: PlaceCategory.park,
    latitude: -22.9667,
    longitude: -43.2250,
    address: 'R. Jardim Botânico, 1008 - Jardim Botânico',
    rating: 4.7,
  ),
  Place(
    id: 'rj-006',
    name: 'Bar do Mineiro',
    description: 'Boteco carioca histórico com feijoada e chope gelado.',
    category: PlaceCategory.bar,
    latitude: -22.9208,
    longitude: -43.1812,
    address: 'R. Paschoal Carlos Magno, 99 - Santa Teresa',
    rating: 4.5,
  ),
];

const List<Place> _genericPlaces = [
  Place(
    id: 'gen-001',
    name: 'Praça Central',
    description: 'Praça central do bairro, ponto de encontro da comunidade.',
    category: PlaceCategory.tourist,
    latitude: 0,
    longitude: 0,
    rating: 4.0,
  ),
  Place(
    id: 'gen-002',
    name: 'Mercado Municipal',
    description: 'Mercado local com produtos frescos e comida regional.',
    category: PlaceCategory.restaurant,
    latitude: 0,
    longitude: 0,
    rating: 4.1,
  ),
  Place(
    id: 'gen-003',
    name: 'Parque Municipal',
    description: 'Parque para atividades ao ar livre e lazer em família.',
    category: PlaceCategory.park,
    latitude: 0,
    longitude: 0,
    rating: 4.2,
  ),
  Place(
    id: 'gen-004',
    name: 'Igreja Matriz',
    description: 'Igreja histórica tombada pelo patrimônio municipal.',
    category: PlaceCategory.church,
    latitude: 0,
    longitude: 0,
    rating: 4.3,
  ),
  Place(
    id: 'gen-005',
    name: 'Museu Regional',
    description: 'Museu com acervo da história e cultura local.',
    category: PlaceCategory.museum,
    latitude: 0,
    longitude: 0,
    rating: 4.0,
  ),
  Place(
    id: 'gen-006',
    name: 'Bar & Restaurante do Centro',
    description: 'O ponto gastronômico mais popular do bairro.',
    category: PlaceCategory.bar,
    latitude: 0,
    longitude: 0,
    rating: 4.4,
  ),
];

/// Retorna uma lista de lugares mock baseada na cidade selecionada.
/// Em produção isso poderia ser substituído por uma chamada à API do Overpass/Google Places.
List<Place> getMockPlacesForCity(String cityName) {
  final lower = cityName.toLowerCase();

  if (lower.contains('são paulo') || lower.contains('sao paulo') || lower.contains('sp')) {
    return _saoPauloPlaces;
  }
  if (lower.contains('recife') || lower.contains('pernambuco')) {
    return _recifePlaces;
  }
  if (lower.contains('rio') || lower.contains('rj')) {
    return _rioDePlacas;
  }

  // Para qualquer outra cidade, retorna lugares genéricos
  return _genericPlaces;
}
