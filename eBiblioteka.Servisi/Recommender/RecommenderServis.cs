using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Servisi.Database;
using MapsterMapper;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Recommender
{
    public class RecommenderServis : IRecommenderServis
    {
        private static object _isLocked = new object();
        private static MLContext _mlContext;
        private static ITransformer _model;
        const string Path = "trainingModel.txt";

        private readonly Db180105Context _context;
        private readonly IMapper _mapper;

        public RecommenderServis(Db180105Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public List<KnjigaDTO> PreporuciKnjige(int korisnikId)
        {

            OsigurajTreniranjeModela();

            var korisnikRezervacije = _context.Rezervacijas
            .Where(r => r.KorisnikId == korisnikId && r.Odobrena == true)
            .Select(r => r.KnjigaId)
            .Distinct()
            .ToList();

            if(!korisnikRezervacije.Any())
            {
                return GetPopularneKnjige();
            }

            var preporuke = new List<(Knjiga knjiga, float score)>();
            var dostupneKnjige = _context.Knjigas.
                Where(x => x.Dostupna == true &&
                    x.IsDeleted == false &&
                    korisnikRezervacije.Contains(x.KnjigaId)).ToList();

            var predictionEngine = _mlContext.Model.CreatePredictionEngine<KnjigaInteraction, ScorePrediction>(_model);

            foreach (var knjiga in dostupneKnjige)
            {
                var prediction = predictionEngine.Predict(new KnjigaInteraction
                {
                    KorisnikId = (uint)korisnikId,
                    KnjigaId = (uint)knjiga.KnjigaId,
                });

                preporuke.Add((knjiga, prediction.Score));
            }

            var topPreporuke = preporuke.OrderByDescending(x => x.score)
                .Take(5).Select(x => x.knjiga).ToList();

            return _mapper.Map<List<KnjigaDTO>>(topPreporuke);
        }

        private void OsigurajTreniranjeModela()
        {
            if (_model == null)
            {
                lock (_isLocked)
                {
                    if (_model == null)
                    {
                        TrenirajModel();
                    }
                }
            }
        }

        private void TrenirajModel()
        {
            if (_mlContext == null)
            {
                _mlContext = new MLContext();
            }

            var trainingData = PrepareTrainingData();
            var dataView = _mlContext.Data.LoadFromEnumerable<KnjigaInteraction>(trainingData);
            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(KnjigaInteraction.KorisnikId),
                MatrixRowIndexColumnName = nameof(KnjigaInteraction.KnjigaId),
                LabelColumnName = nameof(KnjigaInteraction.Label),
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossRegression,
                Alpha = 0.01,
                Lambda = 0.025,
                NumberOfIterations = 100,
                C = 0.00001,
                ApproximationRank = 64
            };

            var trainer = _mlContext.Recommendation().Trainers.MatrixFactorization(options);
            _model = trainer.Fit(dataView);

            using (var fs = new FileStream(Path, FileMode.Create, FileAccess.Write, FileShare.Write))
            {
                _mlContext.Model.Save(_model, dataView.Schema, fs);
                Console.WriteLine("Data saved");
            }
        }

        private List<KnjigaInteraction> PrepareTrainingData()
        {
            var interakcije= new List<KnjigaInteraction>();

            var rezervacije = _context.Rezervacijas
                .Where(x => x.KorisnikId.HasValue && x.KnjigaId.HasValue)
                .GroupBy(x => new { x.KorisnikId, x.KnjigaId })
                .Select(x => new
                {
                    KorisnikId = x.Key.KorisnikId.Value,
                    KnjigaId = x.Key.KnjigaId.Value,
                    Count = x.Count(),
                    Odobrena = x.Any(y => y.Odobrena == true)
                }).ToList();

            foreach (var rezervacija in rezervacije)
            {
                float rating = rezervacija.Odobrena ? 1.0f : 0.5f;

                interakcije.Add(new KnjigaInteraction
                {
                    KorisnikId = (uint)rezervacija.KorisnikId,
                    KnjigaId = (uint)rezervacija.KnjigaId,
                    Label = rating
                });
            }

            return interakcije;
        }

        private List<KnjigaDTO> GetPopularneKnjige()
        {
            var popularneKnjige = _context.Knjigas
                .Where(k => k.Dostupna == true && k.IsDeleted != true)
                .OrderByDescending(k => k.Rezervacijas.Count(r => r.Odobrena == true))
                .ThenByDescending(k => k.Preporuceno == true)
                .ThenByDescending(k => k.KnjigaDana == true)
                .Take(5)
                .ToList();

            return _mapper.Map<List<KnjigaDTO>>(popularneKnjige);
        }

        public class KnjigaInteraction
        {
            [KeyType(count: 100)]
            public uint KorisnikId { get; set; }

            [KeyType(count: 100)]
            public uint KnjigaId { get; set; }

            public float Label { get; set; }
        }

        public class ScorePrediction
        {
            public float Score { get; set; }
        }
    }
}
