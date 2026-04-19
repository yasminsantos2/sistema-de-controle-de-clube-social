package br.com.clubesocial.service;

import br.com.clubesocial.model.Candidato;
import br.com.clubesocial.model.CandidatoStatus;
import br.com.clubesocial.repository.CandidatoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CandidatoService {

    @Autowired
    private CandidatoRepository repository;

    public List<Candidato> listarTodos() {
        return repository.findAll();
    }

    public Candidato buscarPorId(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Candidato não encontrado com ID: " + id));
    }

    @Transactional
    public Candidato salvar(Candidato candidato) {
        // Validação simples: verificar se o CPF já existe
        if (repository.findByCpf(candidato.getCpf()).isPresent()) {
            throw new RuntimeException("Já existe um candidato com este CPF.");
        }
        return repository.save(candidato);
    }

    @Transactional
    public void deletar(Long id) {
        Candidato candidato = buscarPorId(id);
        repository.delete(candidato);
    }

    @Transactional
    public Candidato alterarStatus(Long id, CandidatoStatus novoStatus) {
        Candidato candidato = buscarPorId(id);
        candidato.setStatus(novoStatus);
        return repository.save(candidato);
    }
}
